# -*- mode: Ruby;-*-
outputs="."
inputs=ENV["OCTRC_INPUTS"]


file "#{outputs}/src" => inputs do |t|
  sh "cp -r #{t.source} #{t.name}"
  puts "extractcode ..."
  sh "extractcode --verbose #{t.name} || true"
end

namespace "ort" do
  ortOutputs="#{outputs}/ort"
  file "#{ortOutputs}/.gitignore" do |t|
    sh "mkdir -p #{ortOutputs}"
    gitignore = <<-GITIGNORE
scan-result-reports
downloads
GITIGNORE
    File.open(t.name, 'w') { |file| file.write(gitignore) }
  end
  file "#{ortOutputs}/analyzer-result.yml" => "#{outputs}/src" do |t|
    puts "ort analyzer ..."
    sh "ort --force-overwrite --info -P ort.analyzer.allowDynamicVersions=true analyze --clearly-defined-curations --output-formats JSON,YAML -i #{t.source} -o #{File.dirname(t.name)} || true"
  end

  file "#{ortOutputs}/analyzer-result.packages" => "#{ortOutputs}/analyzer-result.yml" do |t|
    puts "orts list-packages ..."
    sh "orth list-packages -i #{t.source} > #{t.name}"
  end

  file "#{ortOutputs}/downloads" => "#{ortOutputs}/analyzer-result.yml" do |t|
    puts "ort download ..."
    sh "ort download -i #{t.source} -o #{t.name}"
  end

  file "#{ortOutputs}/scan-result.yml" => "#{ortOutputs}/analyzer-result.yml" do |t|
    puts "ort scan ..."
    sh "ort --force-overwrite --info scan -i #{t.source} -o #{File.dirname(t.name)} || true"
  end

  file "#{ortOutputs}/analyzer-result-reports" => "#{ortOutputs}/analyzer-result.yml" do |t|
    puts "ort report for analzyer ..."
    sh "ort --force-overwrite --info report -f StaticHtml,WebApp,Excel,NoticeTemplate,SPDXDocument,GitLabLicensemodel,AsciiDocTemplate,CycloneDx,EvaluatedModel -i #{t.source} -o #{t.name} || true"
  end

  file "#{ortOutputs}/scan-result-reports" => "#{ortOutputs}/scan-result.yml" do |t|
    puts "ort report for scan ..."
    sh "ort --force-overwrite --info report -f StaticHtml,WebApp,Excel,NoticeTemplate,SPDXDocument,GitLabLicensemodel,AsciiDocTemplate,CycloneDx,EvaluatedModel -i #{t.source} -o #{t.name} || true"
  end

  task :analyze => ["#{ortOutputs}/.gitignore",
                    "#{ortOutputs}/analyzer-result.yml",
                    "#{ortOutputs}/analyzer-result.packages",
                    "#{ortOutputs}/analyzer-result-reports",
                   ]
  task :all => [:analyze,
                "#{ortOutputs}/downloads",
                "#{ortOutputs}/scan-result.yml",
                "#{ortOutputs}/scan-result-reports"
               ]
end

namespace "scancode" do
  file "#{outputs}/scancode/src.scancode.json" => "#{outputs}/src" do |t|
    puts "scancode ..."
    sh "scancode.scan.sh #{t.source} #{File.dirname(t.name)}"
  end
  # file "#{outputs}/scancode/manifest.md" => "#{outputs}/scancode/src.scancode.json" do |t|
  #   sh "touch /tmp/config.json"
  #   sh "/opt/vinland-technology-scancode-manifestor/scancode-manifestor -ae -i #{t.source} -c /tmp/config.json -of markdown -- create > #{t.name}"
  # end
  task :run => ["#{outputs}/scancode/src.scancode.json"]
end

namespace "scanoss" do
  file "#{outputs}/scanoss/scanoss.json" => "#{outputs}/src" do |t|
    puts "scanoss json ..."
    sh "mkdir -p #{outputs}/scanoss/"
    sh "scanner -o#{t.name} #{t.source}"
  end
  file "#{outputs}/scanoss/scanoss.spdx.json" => "#{outputs}/src" do |t|
    puts "scanoss spdx ..."
    sh "mkdir -p #{outputs}/scanoss/"
    sh "scanner -fspdx -o#{t.name} #{t.source}"
  end
  multitask :run => ["#{outputs}/scanoss/scanoss.json", "#{outputs}/scanoss/scanoss.spdx.json"]
end

namespace "owasp" do
  file "#{outputs}/owasp/dependency-check-report.json" => "#{outputs}/src" do |t|
    puts "dependency-check.sh ..."
    sh "dependency-check.sh --format ALL --data /dependency-check-data --log #{File.dirname(t.name)}/log --out #{File.dirname(t.name)} --scan #{t.source}"
  end
  multitask :run => ["#{outputs}/owasp/dependency-check-report.json"]
end

namespace "metadata" do
  file "#{outputs}/cmff" => "#{outputs}/src" do |t|
    sh "cmff.sh #{t.source} #{t.name}"
  end

  file "#{outputs}/definitionFiles" => "#{outputs}/src" do |t|
    sh "findDefinitionFiles.sh  #{t.source} #{t.name}"
  end

  multitask :run => ["#{outputs}/cmff", "#{outputs}/definitionFiles"]
end

namespace "cloc" do
  file "#{outputs}/original.cloc.yaml" => inputs do |t|
    sh "cloc -yaml --report-file=#{t.name} #{t.source}"
  end
  file "#{outputs}/extracted.cloc.yaml" => "#{outputs}/src" do |t|
    sh "cloc -yaml --report-file=#{t.name} #{t.source}"
  end

  multitask :run => ["#{outputs}/original.cloc.yaml", "#{outputs}/extracted.cloc.yaml"]
end

task :default => ["metadata:run",
                  "cloc:run",
                  "scancode:run",
                  "ort:analyze", # first analyze, later do scan
                  "scanoss:run",
                  "owasp:run",
                  "ort:all"
                 ]
