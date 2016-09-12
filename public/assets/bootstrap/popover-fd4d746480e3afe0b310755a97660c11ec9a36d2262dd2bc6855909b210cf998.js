"use strict";function _classCallCheck(t,e){if(!(t instanceof e))throw new TypeError("Cannot call a class as a function")}function _inherits(t,e){if("function"!=typeof e&&null!==e)throw new TypeError("Super expression must either be null or a function, not "+typeof e);t.prototype=Object.create(e&&e.prototype,{constructor:{value:t,enumerable:!1,writable:!0,configurable:!0}}),e&&(Object.setPrototypeOf?Object.setPrototypeOf(t,e):t.__proto__=e)}var _createClass=function(){function t(t,e){for(var n=0;n<e.length;n++){var o=e[n];o.enumerable=o.enumerable||!1,o.configurable=!0,"value"in o&&(o.writable=!0),Object.defineProperty(t,o.key,o)}}return function(e,n,o){return n&&t(e.prototype,n),o&&t(e,o),e}}(),_get=function(t,e,n){for(var o=!0;o;){var r=t,i=e,u=n;o=!1,null===r&&(r=Function.prototype);var c=Object.getOwnPropertyDescriptor(r,i);if(void 0!==c){if("value"in c)return c.value;var a=c.get;if(void 0===a)return;return a.call(u)}var l=Object.getPrototypeOf(r);if(null===l)return;t=l,e=i,n=u,o=!0,c=l=void 0}},Popover=function(t){var e="popover",n="4.0.0-alpha.3",o="bs.popover",r="."+o,i=t.fn[e],u=t.extend({},Tooltip.Default,{placement:"right",trigger:"click",content:"",template:'<div class="popover" role="tooltip"><div class="popover-arrow"></div><h3 class="popover-title"></h3><div class="popover-content"></div></div>'}),c=t.extend({},Tooltip.DefaultType,{content:"(string|element|function)"}),a={FADE:"fade",IN:"in"},l={TITLE:".popover-title",CONTENT:".popover-content",ARROW:".popover-arrow"},s={HIDE:"hide"+r,HIDDEN:"hidden"+r,SHOW:"show"+r,SHOWN:"shown"+r,INSERTED:"inserted"+r,CLICK:"click"+r,FOCUSIN:"focusin"+r,FOCUSOUT:"focusout"+r,MOUSEENTER:"mouseenter"+r,MOUSELEAVE:"mouseleave"+r},f=function(i){function f(){_classCallCheck(this,f),_get(Object.getPrototypeOf(f.prototype),"constructor",this).apply(this,arguments)}return _inherits(f,i),_createClass(f,[{key:"isWithContent",value:function(){return this.getTitle()||this._getContent()}},{key:"getTipElement",value:function(){return this.tip=this.tip||t(this.config.template)[0]}},{key:"setContent",value:function(){var e=t(this.getTipElement());this.setElementContent(e.find(l.TITLE),this.getTitle()),this.setElementContent(e.find(l.CONTENT),this._getContent()),e.removeClass(a.FADE).removeClass(a.IN),this.cleanupTether()}},{key:"_getContent",value:function(){return this.element.getAttribute("data-content")||("function"==typeof this.config.content?this.config.content.call(this.element):this.config.content)}}],[{key:"_jQueryInterface",value:function(e){return this.each(function(){var n=t(this).data(o),r="object"==typeof e?e:null;if((n||!/destroy|hide/.test(e))&&(n||(n=new f(this,r),t(this).data(o,n)),"string"==typeof e)){if(void 0===n[e])throw new Error('No method named "'+e+'"');n[e]()}})}},{key:"VERSION",get:function(){return n}},{key:"Default",get:function(){return u}},{key:"NAME",get:function(){return e}},{key:"DATA_KEY",get:function(){return o}},{key:"Event",get:function(){return s}},{key:"EVENT_KEY",get:function(){return r}},{key:"DefaultType",get:function(){return c}}]),f}(Tooltip);return t.fn[e]=f._jQueryInterface,t.fn[e].Constructor=f,t.fn[e].noConflict=function(){return t.fn[e]=i,f._jQueryInterface},f}(jQuery);