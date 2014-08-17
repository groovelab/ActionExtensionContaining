//
//  Action.js
//  KeychainPasswordSafari
//
//  Created by Nanba Takeo on 2014/08/17.
//  Copyright (c) 2014年 GrooveLab. All rights reserved.
//

var Action = function() {};

Action.prototype = {
    
    run: function(arguments) {
        // Here, you can run code that modifies the document and/or prepares
        // things to pass to your action's native code.
        
        var isExist = "0";
        if ( this.getPasswordElement() ) {
            isExist = "1";
        } else {
            alert("no input(type=password)");
        }
        arguments.completionFunction({ "isExist" : isExist })
    },
    
    finalize: function(arguments) {
        // This method is run after the native code completes.
        if ( arguments["keychainPassword"] ) {
            var keychainPassword = arguments["keychainPassword"];
            var passwordElement = this.getPasswordElement();
            if ( passwordElement ) {
                passwordElement.value = keychainPassword;
            }
            return;
        }
     
        alert( "no password!!\nlaunch containing app and save password" );
        window.location.href = "asia.groovelab.ActionExtensionContaining://";
    },
    
    getPasswordElement: function() {
        elements = document.getElementsByTagName("input");
        for ( var i=0; i<elements.length; i++ ){
            var element = elements[i];
            if ( element.type == "password" ) {
                return element;
            }
        }
        return null;
    }
};

var ExtensionPreprocessingJS = new Action
