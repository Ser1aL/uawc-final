$(document).ready(function(){

  $("#inputFile").fileinput({'showPreview':false});

  $('.delivery-type-group label.radio-inline').click(function(event){
    if ($(this).find('input').val() == 'email') {
      $('.form-group.email').removeClass('hidden');
    }
    else {
      $('.form-group.email').addClass('hidden');
    }
  });

  $('.generate-waveform-button').click(function(event){
    event.preventDefault();
    var button = $(this)
    var url = button.closest('form').attr('action');
    $('.loader').removeClass('hidden');
    button.attr('disabled', 'disabled');

    $.ajax({
        url: url,
        method: 'GET'
      })
      .done(function(response){
        button.removeAttr('disabled');
        $('.loader').addClass('hidden');
        var waveform_path = 'waveforms/' + response.waveform
        $('.download-waveform').attr('href', waveform_path).removeClass('hidden');
        var waveform = $('<img>').attr('src', waveform_path)
        $('.waveform-container').append(waveform);
      });
  });

});