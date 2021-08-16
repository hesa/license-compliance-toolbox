# -*- mode: Ruby;-*-
input=File.expand_path(ENV["OCTRC_INPUT"])
output=File.expand_path(".")


file "#{output}/src" => input do |t|
  sh "cp -r #{t.source} #{t.name}"
  puts "extractcode ..."
  sh "extractcode --verbose #{t.name}"\
       " || true"
end

namespace "ort" do
  ortOutput="#{output}/ort"
  ort="ort --force-overwrite --info"
  ortReportFormats="StaticHtml,WebApp,Excel,NoticeTemplate,SPDXDocument,GitLabLicensemodel,AsciiDocTemplate,CycloneDx,EvaluatedModel"

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
    sh "#{ort} -P ort.analyzer.allowDynamicVersions=true analyze"\
       " --clearly-defined-curations"\
       " --output-formats JSON,YAML"\
       " -i #{t.source}"\
       " -o #{File.dirname(t.name)}"\
       " || [ -f #{t.name} ]"
  end

  file "#{ortOutput}/analyzer-result.packages" => "#{ortOutput}/analyzer-result.yml" do |t|
    puts "orts list-packages ..."
    sh "orth list-packages"\
       " -i #{t.source}"\
       " > #{t.name}"
  end

  file "#{ortOutput}/downloads" => "#{ortOutput}/analyzer-result.yml" do |t|
    puts "ort download ..."
    sh "ort download"\
       " -i #{t.source}"\
       " -o #{t.name}"
  end

  file "#{ortOutput}/scan-result.yml" => "#{ortOutput}/analyzer-result.yml" do |t|
    puts "ort scan ..."
    sh "#{ort} scan"\
       " --output-formats JSON,YAML"\
       " -i #{t.source}"\
       " -o #{File.dirname(t.name)}"\
       " || [ -f #{t.name} ]"
  end

  file "#{ortOutput}/analyzer-result-reports" => "#{ortOutput}/analyzer-result.yml" do |t|
    puts "ort report for analzyer ..."
    sh "#{ort} report"\
       " -f #{ortReportFormats}"\
       " -i #{t.source}"\
       " -o #{t.name}"\
       " || [ -d #{t.name}/scan-report-web-app.html ]"
  end

  file "#{ortOutput}/scan-result-reports" => "#{ortOutput}/scan-result.yml" do |t|
    puts "ort report for scan ..."
    sh "#{ort} report"\
       " -f #{ortReportFormats}"\
       " -i #{t.source}"\
       " -o #{t.name}"\
       " || [ -d #{t.name}/scan-report-web-app.html ]"
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
  file "#{output}/scancode/scancode.json" => "#{output}/src" do |t|
    puts "scancode ..."
    sh "scancode.scan.sh #{t.source} #{File.dirname(t.name)}"
  end
  file "#{output}/scancode/scancode.packages.csv" => "#{output}/scancode/scancode.json" do |t|
    sh "scancode.genPackagesCsv.sh #{t.source} > #{t.name}"
  end

  # file "#{output}/scancode/manifest.md" => "#{output}/scancode/src.scancode.json" do |t|
  #   sh "touch /tmp/config.json"
  #   sh "/opt/vinland-technology-scancode-manifestor/scancode-manifestor -ae -i #{t.source} -c /tmp/config.json -of markdown -- create > #{t.name}"
  # end
  task :run => ["#{output}/scancode/scancode.json",
                "#{output}/scancode/scancode.packages.csv"
               ]
end

namespace "scanoss" do
  file "#{output}/scanoss/scanoss.json" => "#{output}/src" do |t|
    puts "scanoss json ..."
    sh "mkdir -p #{output}/scanoss/"
    sh "cd #{t.source} ; scanner -o#{t.name} ."
  end
  file "#{output}/scanoss/scanoss.spdx.json" => "#{output}/src" do |t|
    puts "scanoss spdx ..."
    sh "mkdir -p #{output}/scanoss/"
    sh "cd #{t.source} ; scanner -fspdx -o#{t.name} ."
  end
  multitask :run => ["#{output}/scanoss/scanoss.json",
                     "#{output}/scanoss/scanoss.spdx.json"
                    ]
end

namespace "owasp" do
  file "#{output}/owasp/dependency-check-report.json" => "#{output}/src" do |t|
    puts "dependency-check.sh ..."
    sh "dependency-check.sh"\
       " --format ALL"\
       " --data /dependency-check-data"\
       " --log #{File.dirname(t.name)}/log"\
       " --out #{File.dirname(t.name)}"\
       " --scan #{t.source}"
  end
  multitask :run => ["#{output}/owasp/dependency-check-report.json"
                    ]
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

  multitask :run => ["#{output}/cmff",
                     "#{output}/exiftool.json",
                     "#{output}/definitionFiles"
                    ]
end

namespace "cloc" do
  file "#{output}/original.cloc.yaml" => input do |t|
    sh "cloc -yaml --report-file=#{t.name} #{t.source}"
  end
  file "#{output}/extracted.cloc.yaml" => "#{output}/src" do |t|
    sh "cloc -yaml --report-file=#{t.name} #{t.source}"
  end

  multitask :run => ["#{output}/original.cloc.yaml",
                     "#{output}/extracted.cloc.yaml"
                    ]
end

namespace "yacp" do
  file "#{output}/yacp/_state.json" => ["#{output}/scancode/scancode.json",
                            # "#{output}/scanoss/scanoss.json",
                            # "#{output}/scanoss/scanoss.spdx.json", # not valid SPDX
                            "#{output}/ort/scan-result.json",
                            "#{output}/ort/scan-result-reports/document.spdx.yml"
                           ] do |t|
    sh "yacp"\
       " --sc #{output}/scancode/scancode.json"\
       " --ort #{output}/ort/scan-result.json"\
       " --spdx #{output}/ort/scan-result-reports/document.spdx.yml"\
       " #{File.dirname(t.name)}"
       # " --scanoss #{output}/scanoss/scanoss.json"\
  end

  multitask :run => ["#{output}/yacp"]
end

desc "collect all the data"
task :collect => ["metadata:run",
                  "cloc:run",
                  "scancode:run",
                  "ort:analyze", # first analyze, later do scan
                  "scanoss:run"
                 ]

desc "default task, do everything"
task :default => [:collect,
                  "owasp:run",
                  "ort:all",
                  "yacp:run"
                 ]
