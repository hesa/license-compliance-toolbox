# -*- mode: Ruby;-*-
outputs="."
inputs=ENV["OCTRC_INPUTS"]



file "#{outputs}/src" => inputs do |t|
  sh "cp -r #{t.source} #{t.name}"
  # sh "extractcode --verbose #{t.name}"
end

namespace "ort" do
  file "#{outputs}/ort/.gitignore" do |t|
    sh "mkdir -p #{outputs}/ort"
    gitignore = <<-GITIGNORE
scan-result-reports
downloads
GITIGNORE
    File.open(t.name, 'w') { |file| file.write(gitignore) }
  end
  file "#{outputs}/ort/analyzer-result.yml" => "#{outputs}/src" do |t|
    sh "ort --force-overwrite --info -P ort.analyzer.allowDynamicVersions=true analyze --clearly-defined-curations --output-formats JSON,YAML -i #{t.source} -o #{File.dirname(t.name)} || true"
  end

  file "#{outputs}/ort/analyzer-result.packages" => "#{outputs}/ort/analyzer-result.yml" do |t|
    sh "orth list-packages -i #{t.source} > #{t.name}"
  end

  file "#{outputs}/ort/downloads" => "#{outputs}/ort/analyzer-result.yml" do |t|
    sh "ort download -i #{t.source} -o #{t.name}"
  end

  file "#{outputs}/ort/scan-result.yml" => "#{outputs}/ort/analyzer-result.yml" do |t|
    sh "ort --force-overwrite --info scan -i #{t.source} -o #{File.dirname(t.name)} || true"
  end

  file "#{outputs}/ort/analyzer-result-reports" => "#{outputs}/ort/analyzer-result.yml" do |t|
    sh "ort --force-overwrite --info report -f StaticHtml,WebApp,Excel,NoticeTemplate,SPDXDocument,GitLabLicensemodel,AsciiDocTemplate,CycloneDx,EvaluatedModel -i #{t.source} -o #{t.name} || true"
  end

  file "#{outputs}/ort/scan-result-reports" => "#{outputs}/ort/scan-result.yml" do |t|
    sh "ort --force-overwrite --info report -f StaticHtml,WebApp,Excel,NoticeTemplate,SPDXDocument,GitLabLicensemodel,AsciiDocTemplate,CycloneDx,EvaluatedModel -i #{t.source} -o #{t.name} || true"
  end

  task :run => ["#{outputs}/ort/.gitignore",
                "#{outputs}/ort/analyzer-result.yml",
                "#{outputs}/ort/scan-result.packages",
                "#{outputs}/ort/downloads",
                "#{outputs}/ort/analyzer-result-reports",
                "#{outputs}/ort/scan-result.yml",
                "#{outputs}/ort/scan-result-reports"
               ]
end

namespace "scancode" do
  file "#{outputs}/scancode/src.scancode.json" => "#{outputs}/src" do |t|
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
    sh "mkdir -p #{outputs}/scanoss/"
    sh "scanner -o#{t.name} #{t.source}"
  end
  file "#{outputs}/scanoss/scanoss.spdx.json" => "#{outputs}/src" do |t|
    sh "mkdir -p #{outputs}/scanoss/"
    sh "scanner -fspdx -o#{t.name} #{t.source}"
  end
  multitask :run => ["#{outputs}/scanoss/scanoss.json", "#{outputs}/scanoss/scanoss.spdx.json"]
end

namespace "cmff" do
  file "#{outputs}/cmff" => "#{outputs}/src" do |t|
    sh "cmff.sh #{t.source} #{t.name}"
  end
  multitask :run => ["#{outputs}/cmff"]
end

namespace "cloc" do
  file "#{outputs}/original.cloc" => inputs do |t|
    sh "cloc #{t.source} > #{t.name}"
  end
  file "#{outputs}/extracted.cloc" => "#{outputs}/src" do |t|
    sh "cloc #{t.source} > #{t.name}"
  end
  multitask :run => ["#{outputs}/original.cloc", "#{outputs}/extracted.cloc"]
end

file "#{outputs}/definitionFiles" => "#{outputs}/src" do |t|
  sh "findDefinitionFiles.sh  #{t.source} #{t.name}"
end

multitask :default => ["cmff:run",
                       "cloc:run",
                       "#{outputs}/definitionFiles",
                       "scancode:run",
                       "ort:run",
                       "scanoss:run"
                      ]
