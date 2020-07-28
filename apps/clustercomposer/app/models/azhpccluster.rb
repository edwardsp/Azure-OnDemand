require 'find'

class Azhpccluster < ApplicationRecord

  attr_accessor :staging_template_dir

  # places jobs into the 'projects/default' folder
  def staging_target_dir_name
    "projects/default"
  end

  def staging_target_dir
    OodAppkit.dataroot.join(staging_target_dir_name)
  end

  def staged_dir_exists?
    staged_dir && File.directory?(staged_dir)
  end

  # Create a new azhpccluster from a path and attempt to load a manifest on that path.
  # @return [Azhpccluster] Return a new Azhpccluster based on the path
  def self.new_from_path(path)
    path = Pathname.new(path).expand_path rescue Pathname.new(path)
    azhpcluster = Azhpccluster.new
    azhpcluster.name = ''
    azhpcluster.staging_template_dir = path.to_s

    # Attempt to load a manifest on the path
    #manifest_path = path.join('manifest.yml')
    #if manifest_path.exist?
    #  manifest = Manifest.load manifest_path
    #  workflow.name = manifest.name
    #  workflow.batch_host = manifest.host
    #  workflow.script_name = manifest.script
    #end
    azhpcluster
  end

end
