#!/usr/bin/env ruby

class QemuInvocation
  attr_accessor :ram, :file, :qemu, :flags

  DEFAULT_ARGS = {
    ram: '32M',
    file: 'oriole.iso',
    qemu: 'qemu-system-x86_64',
    flags: [:serial, :no_video, :serial2, :tee]
  }

  OPTION_CONFLICTS = [
    [:monitor, :serial],
    [:monitor, :tee],
  ]

  OPTION_STRINGS = {
    debug: '-S',
    monitor: '-monitor stdio',
    serial: '-serial stdio',
    interrupts: '-d int',
    no_video: '-display none',
    test_mode: '--device isa-debug-exit',
    serial2: '-serial unix:./serial2,nowait,server',
    tee: '| tee last_output',
  }

  def resolve_conflicts(silent: false)
    tmp_flags = @flags.clone
    for flag, conflict in OPTION_CONFLICTS
      if tmp_flags.include? flag and tmp_flags.include? conflict
        tmp_flags.delete conflict
        puts "Warning: removing :#{conflict} due to conflict with :#{flag}" unless silent
      end
    end
    yield tmp_flags
  end

  def resolve_conflicts!(silent: true)
    resolve_conflicts(silent: silent) do |flags|
      @flags = flags
    end
  end

  def initialize(args = {})
    args = DEFAULT_ARGS.merge(args)
    @ram = args[:ram]
    @file = args[:file]
    @qemu = args[:qemu]
    @flags = args[:flags]
  end

  def qemu_command
    "#{@qemu} -s -vga std -no-reboot -m #{ram} -cdrom #{file}"
  end

  def render
    resolve_conflicts do |flags|
      "#{qemu_command} #{flags.map { |f| OPTION_STRINGS[f] }.join(" ")}"
    end
  end
end

trap "SIGINT" do
  exit
end

q = QemuInvocation.new
# q.flags << :monitor
# q.resolve_conflicts!

p q
puts q.render

system(q.render)

