# encoding: utf-8

#
# Representer for Announce messaging
#
class Api::Msg::AudioFileRepresenter < Api::BaseRepresenter

  property :id, writeable: false
  property :filename, writeable: false
  property :size
  property :status, writeable: false

  # the newly uploaded file
  property :upload_path

  # destination for the uploaded file
  property :fixerable_final_path, as: :destination_path

end
