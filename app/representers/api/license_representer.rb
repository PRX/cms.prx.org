# encoding: utf-8

class Api::LicenseRepresenter < Api::BaseRepresenter

  property :id
  property :website_usage
  property :allow_edit
  property :additional_terms

end
