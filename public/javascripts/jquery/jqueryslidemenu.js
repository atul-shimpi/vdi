/*********************
//* jQuery Multi Level CSS Menu #2- By Dynamic Drive: http://www.dynamicdrive.com/
//* Last update: Nov 7th, 08': Limit # of queued animations to minmize animation stuttering
//* Menu avaiable at DD CSS Library: http://www.dynamicdrive.com/style/
*********************/

//Update: April 12th, 10: Fixed compat issue with jquery 1.4x

//Specify full URL to down and right arrow images (23 is padding-right to add to top level LIs with drop downs):
var arrowimages={down:['downarrowclass', '/images/down.gif', 23], right:['rightarrowclass', '/images/right.gif']}

var jqueryslidemenu={

animateduration: {over: 200, out: 100}, //duration of slide in/ out animation, in milliseconds

buildmenu:function(menuid, arrowsvar){
	jQuery(document).ready(function($){
		var $mainmenu=$("#"+menuid+">ul")
		var $headers=$mainmenu.find("ul").parent()
		$headers.each(function(i){
			var $curobj=$(this)
			var $subul=$(this).find('ul:eq(0)')
			this._dimensions={w:this.offsetWidth, h:this.offsetHeight, subulw:$subul.outerWidth(), subulh:$subul.outerHeight()}
			this.istopheader=$curobj.parents("ul").length==1? true : false
			$subul.css({top:this.istopheader? this._dimensions.h+"px" : 0})
			$curobj.children("a:eq(0)").css(this.istopheader? {paddingRight: arrowsvar.down[2]} : {}).append(
				'<img src="'+ (this.istopheader? arrowsvar.down[1] : arrowsvar.right[1])
				+'" class="' + (this.istopheader? arrowsvar.down[0] : arrowsvar.right[0])
				+ '" style="border:0;" />'
			)
			$curobj.hover(
				function(e){
					var $targetul=$(this).children("ul:eq(0)")
					this._offsets={left:$(this).offset().left, top:$(this).offset().top}
					var menuleft=this.istopheader? 0 : this._dimensions.w
					menuleft=(this._offsets.left+menuleft+this._dimensions.subulw>$(window).width())? (this.istopheader? -this._dimensions.subulw+this._dimensions.w : -this._dimensions.w) : menuleft
					if ($targetul.queue().length<=1) //if 1 or less queued animations
						$targetul.css({left:menuleft+"px", width:this._dimensions.subulw+'px'}).slideDown(jqueryslidemenu.animateduration.over)
				},
				function(e){
					var $targetul=$(this).children("ul:eq(0)")
					$targetul.slideUp(jqueryslidemenu.animateduration.out)
				}
			) //end hover
			$curobj.click(function(){
				$(this).children("ul:eq(0)").hide()
			})
		}) //end $headers.each()
		$mainmenu.find("ul").css({display:'none', visibility:'visible'})
	}) //end document.ready
}
}

//build menu with ID="myslidemenu" on page:
jqueryslidemenu.buildmenu("myslidemenu", arrowimages)




//start js for  menu tab
// changes for menu tabs

jQuery(document).ready(function() {
    var submissionlink_chk
    jQuery('#submission_link li').each(function (i) {
        var getval = jQuery(this).html();
        if (getval != ""){
            var c = jQuery('#submission_link ul li a:first').attr("href");
            var a = jQuery('#submission_link a:first').attr("href", c );
            li_chk = true;
            return false;
        }
        else{
            li_chk = false;
        }
    });

    var administrationlink_chk
    jQuery('#administration_link li').each(function (i) {
        var getval = jQuery(this).html();
        if (getval != ""){
            var c = jQuery('#administration_link ul li a:first').attr("href");
            var a = jQuery('#administration_link a:first').attr("href", c );
            administrationlink_chk = true;
            return false;
        }
        else{
            administrationlink_chk = false;
        }
    });

    var submit_rfps_chk
    jQuery('#submit_rfps li').each(function (i) {
        var getval = jQuery(this).html();
        if (getval != ""){
            var c = jQuery('#submit_rfps ul li a:first').attr("href");
            var a = jQuery('#submit_rfps a:first').attr("href", c );
            submit_rfps_chk = true;
            return false;
        }
        else{
            submit_rfps_chk = false;
        }
    });

    var payments_link_chk
    jQuery('#payments_link li').each(function (i) {
        var getval = jQuery(this).html();
        if (getval != ""){
            var c = jQuery('#payments_link ul li a:first').attr("href");
            var a = jQuery('#payments_link a:first').attr("href", c );
            payments_link_chk = true;
            return false;
        }
        else{
            payments_link_chk = false;
        }
    });

    var reports_link_chk
    jQuery('#reports_link li').each(function (i) {
        var getval = jQuery(this).html();
        if (getval != ""){
            var c = jQuery('#reports_link ul li a:first').attr("href");
            var a = jQuery('#reports_link a:first').attr("href", c );
            reports_link_chk = true;
            return false;
        }
        else{
            reports_link_chk = false;
        }
    });

    //start code for current tab

    jQuery('#administration_link li a').each(function (i) {

        var a = window.location.pathname;
        var b = jQuery(this).attr("href");
        //              alert(b);
        if (a == b){
            var cssObj = {
                'background-color' : 'grey',
				'color' : 'white'
            }
            jQuery('#administration_link a:first').css(cssObj);
            jQuery(this).css(cssObj);
			document.getElementById("administration_link").className = "header-button";
        }

    });
	

    jQuery('#submit_rfps li a').each(function (i) {

        var a = window.location.pathname;
        var b = jQuery(this).attr("href");
        //              alert(b);
        if (a == b){
            var cssObj = {
                'background-color' : '#1F1F1F'
            }
            jQuery('#submit_rfps a:first').css(cssObj);
            jQuery(this).css(cssObj);
        }
    });

    jQuery('#submission_link li a').each(function (i) {

        var a = window.location.pathname;
        var b = jQuery(this).attr("href");
        //              alert(b);
        if (a == b){
            var cssObj = {
                'background-color' : '#1F1F1F'
            }
            jQuery('#submission_link a:first').css(cssObj);
            jQuery(this).css(cssObj);
        }
    });

    jQuery('#payments_link li a').each(function (i) {

        var a = window.location.pathname;
        var b = jQuery(this).attr("href");
        //              alert(b);
        if (a == b){
            var cssObj = {
                'background-color' : '#1F1F1F'
            }
            jQuery('#payments_link a:first').css(cssObj);
            jQuery(this).css(cssObj);
        }
    });

    jQuery('#reports_link li a').each(function (i) {

        var a = window.location.pathname;
        var b = jQuery(this).attr("href");
        //              alert(b);
        if (a == b){
            var cssObj = {
                'background-color' : '#1F1F1F'
            }
            jQuery('#reports_link a:first').css(cssObj);
            jQuery(this).css(cssObj);
        }
    });
    var current_location = window.location.pathname;
    var home_location = jQuery('#home_link a').attr("href");
    var projects_location = jQuery('#jobs_link a').attr("href");
    var invoices_location = jQuery('#template_link a').attr("href");
	var config_location = jQuery('#configuration_link a').attr("href");
    var bid_submission_location = jQuery('#bid_submission_link a').attr("href");
    var support_service_location = jQuery('#support_service_link a').attr("href");
	var cluster_location = jQuery('#clusterconfiguration_link a').attr("href");
	var security_location = jQuery('#security_link a').attr("href");
	var storage_location = jQuery('#storage_link a').attr("href");
	var report_location = jQuery('#report_link a').attr("href");
	var release_demo_location = jQuery('#release_demo a').attr("href");
	
    var cssObj = {
        'background-color' : 'grey',
		'color' : 'white'
    }
    if (current_location == home_location){
        jQuery('#home_link a').css(cssObj);
		document.getElementById("home_link").className = "header-button";
    }
        if (current_location == projects_location){
			document.getElementById("jobs_link").className = "header-button";
        jQuery('#jobs_link a').css(cssObj);
		
    }
        if (current_location == invoices_location){
		document.getElementById("template_link").className = "header-button";
        jQuery('#template_link a').css(cssObj);
    }
        if (current_location == bid_submission_location){

        jQuery('#bid_submission_link a').css(cssObj);
    }
            if (current_location == support_service_location){

        jQuery('#support_service_link a').css(cssObj);
    }
		if (current_location == config_location){
			jQuery('#configuration_link a').css(cssObj);
			document.getElementById("configuration_link").className = "header-button";
		}
		if (current_location == cluster_location){
			jQuery('#clusterconfiguration_link a').css(cssObj);
			document.getElementById("clusterconfiguration_link").className = "header-button";
		}
		if (current_location == security_location){
			jQuery('#security_link a').css(cssObj);
			document.getElementById("security_link").className = "header-button";
		}
		if (current_location == storage_location){
			jQuery('#storage_link a').css(cssObj);
			document.getElementById("storage_link").className = "header-button";
		}
		if (current_location == report_location){
			jQuery('#report_link a').css(cssObj);
			document.getElementById("report_link").className = "header-button";
		}
		if (current_location == release_demo_location){
			jQuery('#release_demo a').css(cssObj);
			document.getElementById("release_demo").className = "header-button";
		}

    //  end code for current tab


    if (reports_link_chk == false){
        jQuery('#reports_link').remove();
    }

    if (payments_link_chk == false){
        jQuery('#payments_link').remove();
    }

    if (submit_rfps_chk == false){
        jQuery('#submit_rfps').remove();
    }

    if (administrationlink_chk == false){
        jQuery('#administration_link').remove();
    }
    if (submissionlink_chk == false){
        jQuery('#submission_link').remove();
    }
});

//end js for menu tab