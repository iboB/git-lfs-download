# Copyright (c) Borislav Stanimirov
# SPDX-License-Identifier: MIT
#
require 'tmpdir'
require 'fileutils'
require 'find'

REPO = 'https://github.com/iboB/ten-x.git'

# clone bare repo
tgt_dir = File.basename(REPO, ".git")
raise "'#{tgt_dir}' exist" if File.exist?(tgt_dir)

res = system({'GIT_LFS_SKIP_SMUDGE' => '1'}, "git clone --depth 1 \"#{REPO}\" \"#{tgt_dir}\"")
raise "could not clone #{REPO}" if !res

sha_file = {}

Dir.chdir(tgt_dir) do
  # remove .git dir as it's not needed
  FileUtils.rm_rf(".git")

  files = []

  # positive: collect all lfs files
  all_files = Dir['**/*'].select { File.file? _1 }
  File.readlines(".gitattributes").each { |attrib|
    next if !(attrib =~ /(.*) filter=lfs\s/)
    lfs, all_files = all_files.partition { File.fnmatch?($1, _1) }
    files += lfs
  }

  # TODO:
  # negative: remove 'without' globs

  # TODO:
  # positive: collect 'match' globs

  files.each do |f|
    lines = File.readlines(f)
    if lines[0].strip != 'version https://git-lfs.github.com/spec/v1'
      puts "'#{f}' seems like a false positive for lfs"
      next
    end
    if !(lines[1] =~ /^oid sha256\:([0-9a-f]+)$/)
      puts "bad sha in '#{f}'"
      next
    end
    sha_file[$1] = f
  end
end

puts "Identified #{sha_file.size} files which match the provided globs"

bare_dir = Dir.mktmpdir
FileUtils.mkdir_p bare_dir
END { FileUtils.rm_rf(bare_dir) }

res = system "git clone --depth 1 --bare \"#{REPO}\" \"#{bare_dir}\""
raise "could not clone bare #{REPO}" if !res

# process files
sha_file.each do |sha, file|
  puts "processing #{file}"
  # fetch
  Dir.chdir(bare_dir) do
    res = system "git lfs fetch --include \"#{file}\""
    raise "could not fetch '#{file}'" if !res
  end
  # ... and mov
  Dir.chdir(tgt_dir) do
    FileUtils.mv [bare_dir, 'lfs/objects', sha.unpack('a2a2'), sha].join('/'), file
  end
end
