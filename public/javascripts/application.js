// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function handCursor(obj) {
    obj.style.cursor = 'hand';
    obj.style.cursor = 'pointer';
}	
function charmode(ch){
    if (ch>='A' && ch <='Z')
        return 2;
    if (ch>='a' && ch <='z')
        return 4;
    else
        return 1;
}
function bittotal(num){
    modes=0;
    for (i=0;i<3;i++){
        if (num & 1) modes++;
        num>>>=1;
    }
    return modes;
}
function checkstrong(spw){
	modes = 0;
	for (i = 0; i < spw.length; i++) {
		modes |= charmode(spw[i]);
	}
	var btotal = bittotal(modes);
	if (spw.length < 8 || modes < 2) {
		return false
	} else {
		return true
	}
}
function generatePassword() {
    a2z = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
	opertors = ['!','#','$','%','*','(',')','+','-','^']
	password = ""
	for(var i = 0; i<8; i++) {
	   gen = Math.round(Math.random()* 100)
	   mode = gen % 4
	   if(mode == 0) {
	   	  m = gen % 26
		  password = password + (a2z[m].toUpperCase())
	   } else if(mode == 1) {
	   	  m = gen % 26
		  password = password + a2z[m]
	   } else if(mode == 2) {
	   	  m = gen % 10
		  password = password + opertors[m]
	   } else {
	   	   m = gen % 10
	   	   password = password + m
	   }		  
	}
	return 	password
}	