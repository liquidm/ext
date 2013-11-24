require 'liquid/sysconf'

ProcStat = Struct.new(
  :ppid,
  :pgrp,
  :session,
  :tty_nr,
  :tpgid,
  :flags,
  :minflt,
  :cminflt,
  :majflt,
  :cmajflt,
  :utime,
  :stime,
  :cutime,
  :cstime,
  :priority,
  :nice,
  :num_threads,
  :itrealvalue,
  :starttime,
  :vsize,
  :rss,
  :rsslim,
  :startcode,
  :endcode,
  :startstack,
  :kstkesp,
  :kstkeip,
  :signal,
  :blocked,
  :sigignore,
  :sigcatch,
  :wchan,
  :nswap,
  :cnswap,
  :exit_signal,
  :processor,
  :rt_priority,
  :policy,
  :delayacct_blkio_ticks,
  :guest_time,
  :cguest_time
)

class ProcStat
  def self.read
    stat = File.read("/proc/self/stat").chomp.split
    new(*stat[3..40].map(&:to_i))
  end

  def pagesize
    Sysconf.sysconf(:page_size)
  end
end
