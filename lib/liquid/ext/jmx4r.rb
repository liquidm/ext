require 'active_support/core_ext/hash/keys'
require 'jmx4r'

java_import 'javax.management.RuntimeMBeanException'
java_import 'java.lang.UnsupportedOperationException'

class JMX::MBean

  def self.to_tree
    find_all_by_name("*:*").inject({}) do |result, mbean|
      domain = mbean.object_name.domain
      properties = mbean.object_name.key_property_list_string.split(',')
      mresult = result[domain] ||= {}
      mresult = mresult[properties.shift] ||= {} until properties.empty?
      mbean.to_h(mresult)
      result
    end
  end

  def to_h(hsh = {})
    attributes.keys.inject(hsh) do |result, key|
      result[key.to_sym] = get_value(key)
      result
    end.merge!({
      object_name: object_name.to_s,
    })
  end

  def get_value(key)
    case value = send(key)
    when Java::JavaxManagementOpenmbean::CompositeDataSupport
      Hash[value.to_a].symbolize_keys
    when Enumerable
      value.to_a
    else
      value
    end
  rescue RuntimeMBeanException => e
    raise unless e.cause.is_a?(UnsupportedOperationException)
    nil
  end

end
