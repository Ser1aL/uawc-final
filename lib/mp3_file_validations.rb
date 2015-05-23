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

  # # == Validate announce list
  # #
  # # 'announce-list' should be an array of single-element-arrays
  # # Every single element inside internal array should be a string with a valid URL
  # def validate_announce_list(attribute, object, errors)
  #   if object && object.is_a?(Hash) && object[attribute] && object[attribute].is_a?(Array) &&
  #     !object[attribute].empty?
  #       if object[attribute].map(&:size).uniq == [1]
  #         object[attribute].each do |announce_url|
  #           if announce_url.first =~ URI.regexp
  #             # good
  #           else
  #             errors[attribute] = 'has at least one invalid url'
  #             break
  #           end
  #         end
  #       else
  #         errors[attribute] = 'should be an array of single string-type-element arrays'
  #       end
  #   end
  # end

  # # == Validate Pieces
  # #
  # # 'pieces' should be a concatenated string of SHA1 digests or hexdigests.
  # # This validation checks if the 'pieces' consists of 20-char strings
  # # +validate_length_and_pieces+ does the thorough check of length attributes
  # def validate_pieces_size(attribute, object, errors)
  #   if object && object.is_a?(Hash) && object[attribute]
  #     if object[attribute].bytesize % 20 == 0
  #       # good
  #     else
  #       errors[attribute] = 'is not a valid object. Should be an array of SHA1 20/40-size hashes
  #         (20 for digest, 40 for hexdigest)'
  #     end
  #   else
  #     errors[attribute] = 'is missing'
  #   end
  # end

  # # == Validate Length and Pieces attributes
  # #
  # # The method does thorough validation of length attributes of the torrent file
  # #
  # # According to documentation: http://en.wikipedia.org/wiki/Torrent_file length
  # # attributes of the torrent file are considered valid if condition is met:
  # #
  # #  * (ceil(length / piece length) * 160 = pieces size(bits)
  # #
  # # Here length is either the attribute defined in the root of +info+ or
  # # the sum of all file length attributes (if multiple files)
  # def validate_length_and_pieces(attribute, object, errors)
  #   # attribute should be length but keeping the same structure
  #   if object && object.is_a?(Hash)
  #     if object['length'].to_i > 0
  #       length = object['length']
  #     elsif object['files'] && object['files'].is_a?(Array)
  #       length = object['files'].map { |e| e['length'].to_i }.inject(&:+)
  #     else
  #       errors[attribute] = 'should be defined in either info/length or info/files[]/length'
  #       return
  #     end

  #     if length.to_i <= 0 || object['piece length'].to_i <= 0
  #       errors[attribute] = 'is invalid'
  #       return
  #     end

  #     if (length / object['piece length'].to_f).ceil * 160 == object['pieces'].bytesize * 8
  #       # good
  #     else
  #       errors[attribute] = 'is invalid. Should match condition: ceil(length / piece length) * 160 == pieces size(bits)'
  #     end
  #   else
  #     errors[attribute] = 'is missing'
  #   end
  # end

  # # == Validate File objects
  # #
  # # Validates the format of info/files attribute
  # #
  # # Checks:
  # #
  # #  * validate if +length+ doesn't exist if +files+ attribute is present
  # #  * validate if file paths are unique
  # #  * validate if file lengths are valid integer values
  # #  * validate if paths are string values
  # def validate_files_format(attribute, object, errors)
  #   if object && object.is_a?(Hash) && object[attribute]
  #     if object['length'].to_i > 0 && !object[attribute].empty?
  #       errors[attribute] = 'should not be defined when files are present'
  #     else
  #       object[attribute].each do |file|
  #         # validate length format
  #         if file['length'].to_i.to_s == file['length'].to_s
  #           # good
  #         else
  #           errors[attribute] = 'length should be an integer value'
  #           return
  #         end

  #         # validate path format
  #         if file['path'].is_a?(Array) && file['path'].map(&:class).uniq == [String]
  #           # good
  #         else
  #           errors[attribute] = 'path should be an array of strings'
  #           return
  #         end
  #       end

  #       all_paths = object[attribute].map { |file| file['path'] }
  #       if all_paths.uniq.size != all_paths.size
  #         errors[attribute] = 'paths should be unique'
  #       end
  #     end
  #   end
  # end

  # # == Validate HTTP Seeds
  # #
  # # Checks HTTP seeds to be an array of valid URLs
  # def validate_httpseeds(attribute, object, errors)
  #   if object && object.is_a?(Hash) && object[attribute]
  #     object[attribute].each do |httpseed|
  #       if httpseed =~ URI.regexp
  #         # good
  #       else
  #         errors[attribute] = 'has at least one invalid url'
  #         break
  #       end
  #     end
  #   end
  # end

  # # == Validate Nodes
  # #
  # # Check if nodes is formed properly. Should be an array of ['URL', PORT]
  # def validate_nodes(attribute, object, errors)
  #   if object && object.is_a?(Hash) && object[attribute]
  #     object[attribute].each do |node_array|
  #       if node_array[0].is_a?(String) &&
  #         (node_array[0] =~ URI.regexp || IPAddress.valid?(node_array[0])) &&
  #         node_array[1].to_i.to_s == node_array[1].to_s
  #         # good
  #       else
  #         errors[attribute] = "doesn't have a valid format. Should be an array of ['URL', PORT]"
  #       end
  #     end
  #   end
  # end

end