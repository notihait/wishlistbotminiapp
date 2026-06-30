output_file = "rb_dump.txt"

ignore_dirs = ["vendor", "node_modules", "tmp", ".git", "log", "storage", "public"]

File.open(output_file, "w") do |out|
  Dir.glob("**/*.rb").each do |path|
    next if ignore_dirs.any? { |d| path.include?("/#{d}/") || path.start_with?(d + "/") }

    out.puts "\n" + "=" * 80
    out.puts "FILE: #{path}"
    out.puts "=" * 80
    out.puts File.read(path)
  end
end

puts "Done! Saved to #{output_file}"