sap.ui.define([],function(){"use strict";return{onMercExt:function(a){sap.ushell.Container.getService("CrossApplicationNavigation").isNavigationSupported([{target:{shellHash:"mercadoexterno-display"}}]).done(function(a){a.map(function(a,e){if(a.supported+
===true){var i=sap.ushell&&sap.ushell.Container&&sap.ushell.Container.getService("CrossApplicationNavigation").hrefForExternal({target:{semanticObject:"mercadoexterno",action:"display"},params:{}})||"";sap.m.URLHelper.redirect(i,false)}else{alert("Usuári+
o sem permissão para acessar o link")}})}).fail(function(){alert("Falha ao acessar o link")})},onLog:function(a){sap.ushell.Container.getService("CrossApplicationNavigation").isNavigationSupported([{target:{shellHash:"logdeferimento-display"}}]).done(fun+
ction(a){a.map(function(a,e){if(a.supported===true){var i=sap.ushell&&sap.ushell.Container&&sap.ushell.Container.getService("CrossApplicationNavigation").hrefForExternal({target:{semanticObject:"logdeferimento",action:"display"},params:{}})||"";sap.m.URL+
Helper.redirect(i,false)}else{alert("Usuário sem permissão para acessar o link")}})}).fail(function(){alert("Falha ao acessar o link")})},onContas:function(a){sap.ushell.Container.getService("CrossApplicationNavigation").isNavigationSupported([{target:{s+
hellHash:"deparacontas-display"}}]).done(function(a){a.map(function(a,e){if(a.supported===true){var i=sap.ushell&&sap.ushell.Container&&sap.ushell.Container.getService("CrossApplicationNavigation").hrefForExternal({target:{semanticObject:"deparacontas",a+
ction:"display"},params:{}})||"";sap.m.URLHelper.redirect(i,false)}else{alert("Usuário sem permissão para acessar o link")}})}).fail(function(){alert("Falha ao acessar o link")})},onCriterios:function(a){sap.ushell.Container.getService("CrossApplicationN+
avigation").isNavigationSupported([{target:{shellHash:"deparacriterio-display"}}]).done(function(a){a.map(function(a,e){if(a.supported===true){var i=sap.ushell&&sap.ushell.Container&&sap.ushell.Container.getService("CrossApplicationNavigation").hrefForEx+
ternal({target:{semanticObject:"deparacriterio",action:"display"},params:{}})||"";sap.m.URLHelper.redirect(i,false)}else{alert("Usuário sem permissão para acessar o link")}})}).fail(function(){alert("Falha ao acessar o link")})}}});                       