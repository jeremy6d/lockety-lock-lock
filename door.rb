class Door
  @@door_locked = true

  GPIO_DEVICE_HANDLE = "/sys/class/gpio/gpio4/value"

  RUNNING_IN_DEV = false

  def initialize
    raise "You can't instantiate this."
  end

  def self.unlock!
    if (!@@door_locked || send_device(1))
      @@door_locked = false
    else
      raise "error unlocking door"
    end
  end

  def self.lock!
    if send_device(0)
      @@door_locked = true
    else
      raise "error locking door"
    end
  end

  def self.locked?
    !!@@door_locked
  end

private
  def self.send_device string
    puts "\n\ndoor.rb: putting #{string} on the wire (in dev mode: #{RUNNING_IN_DEV})\n\n"

    RUNNING_IN_DEV || system("echo \"#{string}\" > #{GPIO_DEVICE_HANDLE}") 
  end
end