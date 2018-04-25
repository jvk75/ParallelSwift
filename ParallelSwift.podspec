#
# Be sure to run `pod lib lint NFCNDEFParse.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ParallelSwift'
  s.version          = '1.0.0'
  s.summary          = 'Execute multiple methods in parallel with simple API.
'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Wrapper to simplify parallel execution of methods. With three different excution modes, and optional timeout to prevent locking app.
Made purely in Swift. See Test folder for usege example.
DESC

  s.homepage         = 'https://github.com/jvk75/ParallelSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jari Kalinainen' => 'jari@klubitii.com' }
  s.source           = { :git => 'https://github.com/jvk75/ParallelSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'ParallelSwift/*'
  
end
