# Class: kubernetes::docker::hyperkube
# ===========================
#
# This class is used to define the docker image to use
#
# Parameters
# ----------
#
# [*docker_image*]
#  (String) Docker image string
#  Defaults to 'gcr.io/google_containers/hyperkube-amd64'
#
# [*hyperkube_ver*]
#  (String) docker image version
#  Defaults to 'v1.2.3'
#
class kubernetes::docker::hyperkube (
  $docker_image  = 'gcr.io/google_containers/hyperkube-amd64',
  $hyperkube_ver = 'v1.2.3'
) {

  include ::kubernetes::docker

  $image     = "${docker_image}:${hyperkube_ver}"

  # defaults for the runs
  Docker::Run {
    image      => $::kubernetes::docker::hyperkube::image,
    net        => 'host',
    privileged => true,
  }
}
