# Description: This file contains the file resources for the deployment

# data.template_file.version.rendered
data "template_file" "version" {
  template = file("../.version")
}


