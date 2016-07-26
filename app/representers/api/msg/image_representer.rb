# encoding: utf-8

#
# Representer for Announce messaging
#
class Api::Msg::ImageRepresenter < Api::BaseRepresenter

  property :id, writeable: false
  property :filename
  property :size
  property :caption
  property :credit
  property :status, writeable: false

  # the newly uploaded file
  property :upload_path

  # destination for the uploaded file
  property :fixerable_final_path, as: :destination_path

end
