(function(window, $, undefined){
  "use strict";

  // Ensure that Object.create is availible...
  // if (typeof Object.create !== "function") {
  //   Object.create = function(o) {
  //     function F() {}
  //     F.prototype = o;
  //     return new F();
  //   };
  // }

  // Set up the SCAPE namespace
  if (window.SCAPE === undefined) {
    window.SCAPE = {};
  }

  $.extend(SCAPE, {
  //temporarily used until page ready event sorted... :(
  //This is a copy of the template held in the tagging page.
  tag_palette_template:
    '<li class="ui-li ui-li-static ui-body-c">'+
    '<div class="available-tag palette-tag"><%= tag_id %></div>&nbsp;&nbsp;Tag <%= tag_id %>'+
    '</li>',

  //temporarily used until page ready event sorted... :(
  //This is a copy of the template held in the tagging page.
  substitution_tag_template:
    '<li class="ui-li ui-li-static ui-body-c" data-split-icon="delete">'+
    '<div class="substitute-tag palette-tag"><%= original_tag_id %></div>&nbsp;&nbsp;Tag <%= original_tag_id %> replaced with Tag <%= replacement_tag_id %>&nbsp;&nbsp;<div class="available-tag palette-tag"><%= replacement_tag_id %></div>'+
    '<input id="plate-substitutions-<%= original_tag_id %>" name="plate[substitutions][<%= original_tag_id %>]" type="hidden" value="<%= replacement_tag_id %>" />'+
    '</li>',

  displayReason: function() {
    if($('.reason:visible').length === 0) {
      $('#'+$('#state option:selected').val()).slideDown('slow').find('select:disabled').removeAttr('disabled');
    } 
    else {
      $('.reason').not('#'+$('#state option:selected').val()).slideUp('slow', function(){
        $('#'+$('#state option:selected').val()).slideDown('slow').find('select:disabled').removeAttr('disabled');
      });
    }

  },

  dim: function() { $(this).fadeTo('fast', 0.2); },

  PlateViewModel: function(plate, plateElement) {
    // Using the 'that' pattern...
    // ...'thisInstance' refers to the object created by this constructor.
    // ...'this' used in any of the functions will be set at runtime.
    var thisInstance          = this;
    thisInstance.plateElement = plateElement;
    thisInstance.plate        = plate;


    // Returns a string name of all the aliquots in a particular pool.
    // thisInstance.aliquotsInPool = function(pool_id) {
    //   return thisInstance.plate.pools[pool_id].wells.map(function(well) { return '.aliquot.'+well; }).join(',');
    // };

    thisInstance.changeWellColour = function(fromClass, toClass) {
      $('.aliquot.'+fromClass).toggleClass(fromClass +' '+ toClass);
    };

    thisInstance.colourPools = function() {
      thisInstance.plateElement.find('.aliquot').
        removeClass('red green blue yellow').
        each(function(index){
          var pool = $(this).data('pool');
          $(this).addClass('colour-'+pool);
        });
    };

    thisInstance['summary-view'] = function(){
      $('#summary-information').fadeIn('fast');
      thisInstance.changeWellColour('colour-6','green');
    };

    thisInstance['pools-view'] = function(){
      $('#pools-information').fadeIn('fast');

      // thisInstance.changeWellColour('green','colour-6');
      thisInstance.colourPools();
    };

    thisInstance['samples-view'] = function(){
      $('#samples-information').fadeIn('fast');
      thisInstance.changeWellColour('colour-6','green');
    };


    thisInstance.viewChangeHandler = function(event){
      var viewName = $(this).val();

      $('#plate-summary-div ul:visible').fadeOut('fast', function(){
        thisInstance[viewName]();
      });
    };

    thisInstance.highLightPoolHandler = function(event) {
      var pool = $(this).data('pool');

      thisInstance.plateElement.
        find('.aliquot[data-pool='+pool+']').
        removeClass('red green blue yellow').
        addClass('selected-aliquot');
    };
  },

  illuminaBPlateView: function(plate, control) {
    var plateElement = $(this);
    control = $(control);

    var viewModel = new SCAPE.PlateViewModel(plate, plateElement);

    control.delegate('input:radio', 'change', viewModel.viewChangeHandler);

    plateElement.delegate('.aliquot', 'click', viewModel.highLightPoolHandler );
    return this;
  }

  });

  // Extend jQuery prototype...
  $.extend($.fn, {
    illuminaBPlateView: SCAPE.illuminaBPlateView
  });


  // ########################################################################
  // # Page events....
  $('#search-page').live('pageinit', function(event){
    // Users should start the page by scanning in...
    $('#card_id').focus();

    $('#card_id').live('blur', function(){
      if ($(this).val()) {
        $('.ui-header').removeClass('ui-bar-a').addClass('ui-bar-b');
      } else {
        $('.ui-header').removeClass('ui-bar-b').addClass('ui-bar-a');
      }
    });

    // Trap the carriage return sent by the swipecard reader
    $("#card_id").live("keydown", function(e) {
      var code=e.charCode || e.keyCode;
      if (code==13) {
        $("#plate_barcode").focus();
        return false;
      }
    });

    // Fill in the plate barcode with the plate links barcode
    $(".plate_link").click(function() {
      $('#plate_barcode').val($(this).attr('id').substr(6));
      $('#plate-search-form').submit();
      return false;
    });

  });


  $('#plate-show-page').live('pagecreate', function(event) {

    var tabsForState = '#'+SCAPE.plate.tabStates[SCAPE.plate.state].join(', #');

    $('#navbar li').not(tabsForState).remove();
    $('#'+SCAPE.plate.tabStates[SCAPE.plate.state][0]).find('a').addClass('ui-btn-active');


    SCAPE.linkHandler = function(){
      var targetTab = $(this).attr('rel');
      var targetIds = '#'+SCAPE.plate.tabViews[targetTab].join(', #');

      $('.scape-ui-block').
        not(targetIds).
        filter(':visible').
        fadeOut( function(){ $(targetIds).fadeIn(); } );
    };

    $('.navbar-link').live('click', SCAPE.linkHandler);
  });

  $('#plate-show-page').live('pageinit', function(event){
    var targetTab = SCAPE.plate.tabStates[SCAPE.plate.state][0];
    var targetIds = '#'+SCAPE.plate.tabViews[targetTab].join(', #');

    $(targetIds).not(':visible').fadeIn();

    $('#well-failing .plate-view .aliquot').
      not('.permanent-failure').
      toggle(
        function(){
      $(this).hide('fast', function(){
        var failing = $(this).toggleClass('good failed').show().hasClass('failed');
        $(this).find('input:hidden')[failing ? 'attr' : 'removeAttr']('checked', 'checked');
      });
    },

    function() {
      $(this).hide('fast', function(){
        var failing = $(this).toggleClass('failed good').show().hasClass('failed');
        $(this).find('input:hidden')[failing ? 'attr' : 'removeAttr']('checked', 'checked');
      });
    }
    );

    // Set up the plate element as an illuminaBPlate...
    $('#plate').illuminaBPlateView(SCAPE.plate, '#plate-view-control');

    // State changes reasons...
    SCAPE.displayReason();
    $('#state').live('change', SCAPE.displayReason);
  });


  $('#admin-page').live('pageinit',function(event) {

    $('#plate_edit').submit(function() {
      if ($('#card_id').val().length === 0) {
        alert("Please scan your swipecard...");
        return false;
      }
    });

    // Trap the carriage return sent by the swipecard reader
    $("#card_id").live("keydown", function(e) {
      var code=e.charCode || e.keyCode;
      if (code==13) return false;
    });

    SCAPE.displayReason();
    $('#state').live('click',SCAPE.displayReason);
  });


  $('#tag-creation-page').live('pageinit', function(){

    $.extend(window.SCAPE, {

      tagpaletteTemplate     : _.template(SCAPE.tag_palette_template),
      substitutionTemplate  : _.template(SCAPE.substitution_tag_template),

      updateTagpalette  : function() {
        var tagpalette = $('#tag-palette');

        tagpalette.empty();

        var currentTagGroup   = $(window.tags_by_name[$('#plate_tag_layout_template_uuid option:selected').text()]);
        var currentlyUsedTags = $('.aliquot').map(function(){ return parseInt($(this).text(), 10); });
        var unusedTags        = _.difference(currentTagGroup, currentlyUsedTags);
        var listItems         = unusedTags.reduce(
          function(memo, tagId) { return memo + SCAPE.tagpaletteTemplate({tag_id: tagId}); }, '<li data-role="list-divider" class="ui-li ui-li-divider ui-btn ui-bar-b ui-corner-top ui-btn-up-undefined">Replacement Tags</li>');

          tagpalette.append(listItems);
          $('#tag-palette li:last').addClass('ui-li ui-li-static ui-body-c ui-corner-bottom');

      },

      tagSubstitutionHandler : function() {
        var sourceAliquot = $(this);
        var originalTag   = sourceAliquot.text();

        // Dim other tags...
        $('.aliquot').not('.tag-'+originalTag).each(SCAPE.dim);

        SCAPE.updateTagpalette();

        // Show the tag palette...
        $('#instructions').fadeOut(function(){
          $('#replacement-tags').fadeIn();
        });


        function paletteTagHandler() {
          var newTag = $(this).text();

          // Find all the aliquots using the original tag
          // swap their tag classes and text
          $('.aliquot.tag-'+originalTag).
            hide().
            removeClass('tag-'+originalTag).
            addClass('tag-'+newTag).
            text(newTag).
            addClass('selected-aliquot').
            show('fast');

          // Add the substitution as a hidden field and li
          $('#substitutions ul').append(SCAPE.substitutionTemplate({original_tag_id: originalTag, replacement_tag_id: newTag}));
          $('#substitutions ul').listview('refresh');

          SCAPE.resetHandler();
        }
        // Remove old behaviour and add the new to available-tags
        $('.available-tag').unbind().click(paletteTagHandler);

      },


      update_layout : function () {
        var tags = $(window.tag_layouts[$('#plate_tag_layout_template_uuid option:selected').text()]);

        tags.each(function(index) {
          $('#tagging-plate #aliquot_'+this[0]).
            hide('slow').text(this[1][1]).
            addClass('aliquot colour-'+this[1][0]).
            addClass('tag-'+this[1][1]).
            show('slow');
        });

        SCAPE.resetHandler();
        SCAPE.resetSubstitutions();
      },

      resetSubstitutions : function() {
        $('#substitutions ul').empty();
        $('#tagging-plate .aliquot').removeClass('selected-aliquot');
      },

      resetHandler : function() {
        $('.aliquot').css('opacity', 1);
        $('.available-tags').unbind();
        $('#replacement-tags').fadeOut(function(){
          $('#instructions').fadeIn();
        });
      }

    });


    $('#tagging-plate .aliquot').removeClass('green orange red');

    SCAPE.update_layout();
    $('#plate_tag_layout_template_uuid').change(SCAPE.update_layout);
    $('#tagging-plate .aliquot').toggle(SCAPE.tagSubstitutionHandler, SCAPE.resetHandler);

  });

})(window, jQuery);

