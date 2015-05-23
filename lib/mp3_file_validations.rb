# = Torrent File Validations
#
# The validations listed here are something more specific to the
# bit-torrent format
#
# Validations are built as chainable calls.
# The object that is passed through is an errors hash.
# In case of invalid input every validation call modifies the errors
# hash by adding the element with the key of +attribute+ and value as a +message+
module Mp3FileValidations

  def validate_mime_type(attribute, object, errors)
    mime_type = IO.popen(
      ["file", "--brief", "--mime-type", object.path],
      in: :close,
      err: :close
    ).read.chomp

    if mime_type == 'audio/mpeg'
      # ok
    else
      errors[attribute] = "is invalid. You should specify mp3 file"
    end
  end
end