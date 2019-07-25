# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Init password strength
$(document).on 'ready page:load', ->
  options = {};
  options.common = {
    minChar: 8;
  };
  options.rules = {
    activated: {
      wordTwoCharacterClasses: true,
      wordRepetitions: true
    }
  };
  options.ui = {
    showErrors: true
  };
  $(".password-strength input[type='password']").pwstrength(options);
  $(".change-password input[type='password']").pwstrength(options);
  $(".edit-password input[type='password']").pwstrength(options);