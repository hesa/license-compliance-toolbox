# -*- mode: Ruby;-*-
output="."
input=ENV["OCTRC_INPUT"]


file "#{output}/src" => input do |t|
  sh "cp -r #{t.source} #{t.name}"
  puts "extractcode ..."
  sh "extractcode --verbose #{t.name} || true"
end

namespace "ort" do
  ortOutput="#{output}/ort"
  file "#{ortOutput}/.gitignore" do |t|
    sh "mkdir -p #{ortOutput}"
    gitignore = <<-GITIGNORE
scan-result-reports
downloads
GITIGNORE
    File.open(t.name, 'w') { |file| file.write(gitignore) }
  end
  file "#{ortOutput}/analyzer-result.yml" => "#{output}/src" do |t|
    puts "ort analyzer ..."
    sh "ort --force-overwrite --info -P ort.analyzer.allowDynamicVersions=true analyze --clearly-defined-curations --output-formats JSON,YAML -i #{t.source} -o #{File.dirname(t.name)} || true"
  end

  file "#{ortOutput}/analyzer-result.packages" => "#{ortOutput}/analyzer-result.yml" do |t|
    puts "orts list-packages ..."
    sh "orth list-packages -i #{t.source} > #{t.name}"
  end

  file "#{ortOutput}/downloads" => "#{ortOutput}/analyzer-result.yml" do |t|
    puts "ort download ..."
    sh "ort download -i #{t.source} -o #{t.name}"
  end

  file "#{ortOutput}/scan-result.yml" => "#{ortOutput}/analyzer-result.yml" do |t|
    puts "ort scan ..."
    sh "ort --force-overwrite --info scan -i #{t.source} -o #{File.dirname(t.name)} || true"
  end

  file "#{ortOutput}/analyzer-result-reports" => "#{ortOutput}/analyzer-result.yml" do |t|
    puts "ort report for analzyer ..."
    sh "ort --force-overwrite --info report -f StaticHtml,WebApp,Excel,NoticeTemplate,SPDXDocument,GitLabLicensemodel,AsciiDocTemplate,CycloneDx,EvaluatedModel -i #{t.source} -o #{t.name} || true"
  end

  file "#{ortOutput}/scan-result-reports" => "#{ortOutput}/scan-result.yml" do |t|
    puts "ort report for scan ..."
    sh "ort --force-overwrite --info report -f StaticHtml,WebApp,Excel,NoticeTemplate,SPDXDocument,GitLabLicensemodel,AsciiDocTemplate,CycloneDx,EvaluatedModel -i #{t.source} -o #{t.name} || true"
  end

  task :analyze => ["#{ortOutput}/.gitignore",
                    "#{ortOutput}/analyzer-result.yml",
                    "#{ortOutput}/analyzer-result.packages",
                    "#{ortOutput}/analyzer-result-reports",
                   ]
  task :all => [:analyze,
                "#{ortOutput}/downloads",
                "#{ortOutput}/scan-result.yml",
                "#{ortOutput}/scan-result-reports"
               ]
end

namespace "scancode" do
  file "#{output}/scancode/src.scancode.json" => "#{output}/src" do |t|
    puts "scancode ..."
    sh "scancode.scan.sh #{t.source} #{File.dirname(t.name)}"
  end
  # file "#{output}/scancode/manifest.md" => "#{output}/scancode/src.scancode.json" do |t|
  #   sh "touch /tmp/config.json"
  #   sh "/opt/vinland-technology-scancode-manifestor/scancode-manifestor -ae -i #{t.source} -c /tmp/config.json -of markdown -- create > #{t.name}"
  # end
  task :run => ["#{output}/scancode/src.scancode.json"]
end

namespace "scanoss" do
  file "#{output}/scanoss/scanoss.json" => "#{output}/src" do |t|
    puts "scanoss json ..."
    sh "mkdir -p #{output}/scanoss/"
    sh "scanner -o#{t.name} #{t.source}"
  end
  file "#{output}/scanoss/scanoss.spdx.json" => "#{output}/src" do |t|
    puts "scanoss spdx ..."
    sh "mkdir -p #{output}/scanoss/"
    sh "scanner -fspdx -o#{t.name} #{t.source}"
  end
  multitask :run => ["#{output}/scanoss/scanoss.json", "#{output}/scanoss/scanoss.spdx.json"]
end

namespace "owasp" do
  file "#{output}/owasp/dependency-check-report.json" => "#{output}/src" do |t|
    puts "dependency-check.sh ..."
    sh "dependency-check.sh --format ALL --data /dependency-check-data --log #{File.dirname(t.name)}/log --out #{File.dirname(t.name)} --scan #{t.source}"
  end
  multitask :run => ["#{output}/owasp/dependency-check-report.json"]
end

namespace "metadata" do
  file "#{output}/cmff" => "#{output}/src" do |t|
    sh "cmff.sh #{t.source} #{t.name}"
  end

  file "#{output}/exiftool.json" => "#{output}/src" do |t|
    sh "exiftool-dir.sh #{t.source} #{t.name}"
  end

  file "#{output}/definitionFiles" => "#{output}/src" do |t|
    sh "findDefinitionFiles.sh  #{t.source} #{t.name}"
  end

  multitask :run => ["#{output}/cmff", "#{output}/exiftool.json", "#{output}/definitionFiles"]
end

namespace "cloc" do
  file "#{output}/original.cloc.yaml" => input do |t|
    sh "cloc -yaml --report-file=#{t.name} #{t.source}"
  end
  file "#{output}/extracted.cloc.yaml" => "#{output}/src" do |t|
    sh "cloc -yaml --report-file=#{t.name} #{t.source}"
  end

  multitask :run => ["#{output}/original.cloc.yaml", "#{output}/extracted.cloc.yaml"]
end

task :default => ["metadata:run",
                  "cloc:run",
                  "scancode:run",
                  "ort:analyze", # first analyze, later do scan
                  "scanoss:run",
                  "owasp:run",
                  "ort:all"
                 ]
