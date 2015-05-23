$(document).ready(function(){

  // $('.main-tab-panel a').click(function (e) {
  //   e.preventDefault();
  //   $(this).tab('show');
  // });

  // $('.main-tab-panel li a.active').tab('show');

  $("#inputFile").fileinput({'showPreview':false});

  // $('.more-button').click(function (event) {
  //   event.preventDefault();
  //   var $form_group = $(this).closest('.form-group');
  //   var $template = $form_group.find('.row.template').clone();
  //   $template.removeClass('template').addClass('top-margin-1');
  //   $form_group.find('.template-container').append($template.prop('outerHTML'));
  // });

  $('.delivery-type-group label.radio-inline').click(function(event){
    if ($(this).find('input').val() == 'email') {
      $('.form-group.email').removeClass('hidden');
    }
    else {
      $('.form-group.email').addClass('hidden');
    }
  });

});