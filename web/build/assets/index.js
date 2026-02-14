
function Div(data)
{
  this.div = document.createElement("div");
  this.div.classList.add("div_"+data.name);

  this.style = document.createElement("style");
  this.style_css = document.createTextNode("");
  this.style.appendChild(this.style_css);

  this.setCss(data.css);
  this.setContent(data.content);

  //build js sandbox
  var params = {"self":{},"window":{}}
  for(var k in window) //overload all window (global) keys
    params[k] = {};

  //whitelist
  params.div = this.div;

  //build proto/params
  this.proto_params = [];
  for(var k in params)
    this.proto_params.push(params[k]);
  this.proto = Object.keys(params).join(",");
}

Div.prototype.setCss = function(css)
{
  this.style_css.nodeValue = css;
}

Div.prototype.setContent = function(content)
{
  this.div.innerHTML = content;
}

Div.prototype.executeJS = function(js)
{
  (new Function(this.proto,js)).apply(null,this.proto_params);
}

Div.prototype.addDom = function()
{
  document.body.appendChild(this.div);
  document.head.appendChild(this.style);
}

Div.prototype.removeDom = function()
{
  document.body.removeChild(this.div);
  document.head.removeChild(this.style);
}

window.addEventListener("load", function() {
    var divs = {}

    //MESSAGES
    window.addEventListener("message", function(evt) { //lua actionions
        var data = evt.data;

        if (data.action == "cfg") {
            cfg = data.cfg
        }
        else if (data.action == "set_div") {
			var div = divs[data.name];
			if (div)
				div.removeDom();

			divs[data.name] = new Div(data)
			divs[data.name].addDom();
		}
		else if (data.action == "set_div_css") {
			var div = divs[data.name];
			if (div)
				div.setCss(data.css);
		}
		else if (data.action == "set_div_content") {
			var div = divs[data.name];
			if (div)
				div.setContent(data.content);
		}
        else if (data.action == "div_execjs") {
            var div = divs[data.name];
            if (div)
                div.executeJS(data.js);
        }
        else if (data.action == "remove_div") {
            var div = divs[data.name];
            if (div)
                div.removeDom();

            delete divs[data.name];
        }
    });
});