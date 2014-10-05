require_relative 'helpers'

test "it should allow the source to be changed and the image chained" do
  original_src = '/path/to/src'
  new_src = '/path/to/new/dest'

  image = MyImage.new original_src, '/path/to/dst'

  assert_equal image.src!(new_src), image
  assert_equal image.src, new_src
end

test "it should allow the destination to be changed and the image chained" do
  original_dst = '/path/to/dst'
  new_dst = '/path/to/new/dst'

  image = MyImage.new '/path/to/src', original_dst

  assert_equal image.dst!(new_dst), image
  assert_equal image.dst, new_dst
end

test "it should define a version" do
  class BlurredImage
    include Vips::Process
    version(:blurred) { 'blurred' }
  end

  image = MyImage.new '/path/to/src'

  assert image.respond_to?(:blurred_version)
end

test "it should keep the versions within the class they were defined" do
  class Image1 < Vips::Process::Base
    version(:v1) { 'v1' }
  end

  class Image2 < Vips::Process::Base
    version(:v2) { 'v2' }
  end

  assert_equal Image1.versions, [:v1]
  assert_equal Image2.versions, [:v2]
end

test "it should allow a version to be composed out of other versions" do print 'S' end
test "it should allow a version to be composed out of other versions and have a block" do print 'S' end
test "it should reset the settings after process! runs" do print 'S' end
