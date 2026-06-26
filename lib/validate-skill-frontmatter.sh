#!/usr/bin/env bash
# Shared helper: validate YAML frontmatter of every SKILL.md under a skills
# directory. Sourced by validate-skill-library.sh and validate-cursor-skills.sh.
# Emits "<path>\t<message>" lines for invalid frontmatter; silent on success.

validate_skill_frontmatter() {
    local skills_dir="$1"

    ruby -ryaml -e '
Encoding.default_external = Encoding::UTF_8
skills_dir = ARGV.fetch(0)

Dir.glob(File.join(skills_dir, "*", "SKILL.md")).sort.each do |path|
  text = File.read(path, mode: "r:UTF-8")
  unless text.start_with?("---\n")
    puts "#{path}\tmissing YAML frontmatter"
    next
  end

  parts = text.split(/^---\s*$/, 3)
  unless parts.length >= 3
    puts "#{path}\tmissing closing YAML frontmatter delimiter"
    next
  end

  begin
    YAML.safe_load(parts.fetch(1), aliases: true)
  rescue Psych::Exception => e
    message = e.message.lines.first&.strip || e.class.name
    puts "#{path}\t#{message}"
  end
end
' "$skills_dir"
}
