;(function(window) {

var svgSprite = '<svg>' +
  ''+
    '<symbol id="icon-more" viewBox="0 0 1024 1024">'+
      ''+
      '<path d="M224 608c-52.928 0-96-43.072-96-96s43.072-96 96-96c52.928 0 96 43.072 96 96S276.928 608 224 608z"  ></path>'+
      ''+
      '<path d="M512 608c-52.928 0-96-43.072-96-96s43.072-96 96-96c52.928 0 96 43.072 96 96S564.928 608 512 608z"  ></path>'+
      ''+
      '<path d="M800 608c-52.928 0-96-43.072-96-96s43.072-96 96-96c52.928 0 96 43.072 96 96S852.928 608 800 608z"  ></path>'+
      ''+
    '</symbol>'+
  ''+
    '<symbol id="icon-fasong" viewBox="0 0 1024 1024">'+
      ''+
      '<path d="M63 553.863l309.253 96.749L753.13 316.615 457.987 676.367l330.729 105.435 170.301-675.95L63 553.863zM447.551 915.411 556.427 761.71l-108.876-32.3L447.551 915.411z"  ></path>'+
      ''+
    '</symbol>'+
  ''+
    '<symbol id="icon-image" viewBox="0 0 1024 1024">'+
      ''+
      '<path d="M341.333333 341.333333q0 42.666667-29.866667 72.533333t-72.533333 29.866667-72.533333-29.866667-29.866667-72.533333 29.866667-72.533333 72.533333-29.866667 72.533333 29.866667 29.866667 72.533333zM887.466667 546.133333l0 238.933333-750.933333 0 0-102.4 170.666667-170.666667 85.333333 85.333333 273.066667-273.066667zM938.666667 170.666667l-853.333333 0q-6.933333 0-12 5.066667t-5.066667 12l0 648.533333q0 6.933333 5.066667 12t12 5.066667l853.333333 0q6.933333 0 12-5.066667t5.066667-12l0-648.533333q0-6.933333-5.066667-12t-12-5.066667zM1024 187.733333l0 648.533333q0 35.2-25.066667 60.266667t-60.266667 25.066667l-853.333333 0q-35.2 0-60.266667-25.066667t-25.066667-60.266667l0-648.533333q0-35.2 25.066667-60.266667t60.266667-25.066667l853.333333 0q35.2 0 60.266667 25.066667t25.066667 60.266667z"  ></path>'+
      ''+
    '</symbol>'+
  ''+
    '<symbol id="icon-icchatbarface" viewBox="0 0 1076 1024">'+
      ''+
      '<path d="M519.606456 0C806.108073 0 1039.212908 229.692442 1039.212908 512 1039.212908 794.319293 806.108078 1024 519.606456 1024 233.104835 1024 0 794.319293 0 512 0 229.692442 233.104835 0 519.606456 0L519.606456 0ZM974.265083 512C974.265083 264.976486 770.311747 64.008801 519.606456 64.008801 268.901161 64.008801 64.94783 264.976486 64.94783 512 64.94783 759.035249 268.901161 960.002934 519.606456 960.002934 770.311747 960.002934 974.265083 759.035249 974.265083 512L974.265083 512ZM747.388283 372.424438C827.578726 372.424438 826.721331 495.161754 746.49516 495.161754 666.304717 495.161754 667.162112 372.424438 747.388283 372.424438L747.388283 372.424438ZM318.856453 607.397166C319.773389 608.676168 412.193654 736.001464 528.013711 736.001464L528.263782 736.001464C595.176484 735.907594 659.77897 692.644449 720.320732 607.444101L773.538893 644.124488C700.064727 747.559424 617.480714 799.998531 528.013711 799.998531 378.135936 799.998531 270.211077 650.507766 265.674015 644.124488L318.856453 607.397166 318.856453 607.397166ZM292.741565 372.424438C372.9201 372.424438 372.074614 495.161754 291.836534 495.161754 211.657999 495.161754 212.503491 372.424438 292.741565 372.424438L292.741565 372.424438Z"  ></path>'+
      ''+
    '</symbol>'+
  ''+
'</svg>'
var script = function() {
    var scripts = document.getElementsByTagName('script')
    return scripts[scripts.length - 1]
  }()
var shouldInjectCss = script.getAttribute("data-injectcss")

/**
 * document ready
 */
var ready = function(fn){
  if(document.addEventListener){
      document.addEventListener("DOMContentLoaded",function(){
          document.removeEventListener("DOMContentLoaded",arguments.callee,false)
          fn()
      },false)
  }else if(document.attachEvent){
     IEContentLoaded (window, fn)
  }

  function IEContentLoaded (w, fn) {
      var d = w.document, done = false,
      // only fire once
      init = function () {
          if (!done) {
              done = true
              fn()
          }
      }
      // polling for no errors
      ;(function () {
          try {
              // throws errors until after ondocumentready
              d.documentElement.doScroll('left')
          } catch (e) {
              setTimeout(arguments.callee, 50)
              return
          }
          // no errors, fire

          init()
      })()
      // trying to always fire before onload
      d.onreadystatechange = function() {
          if (d.readyState == 'complete') {
              d.onreadystatechange = null
              init()
          }
      }
  }
}

/**
 * Insert el before target
 *
 * @param {Element} el
 * @param {Element} target
 */

var before = function (el, target) {
  target.parentNode.insertBefore(el, target)
}

/**
 * Prepend el to target
 *
 * @param {Element} el
 * @param {Element} target
 */

var prepend = function (el, target) {
  if (target.firstChild) {
    before(el, target.firstChild)
  } else {
    target.appendChild(el)
  }
}

function appendSvg(){
  var div,svg

  div = document.createElement('div')
  div.innerHTML = svgSprite
  svg = div.getElementsByTagName('svg')[0]
  if (svg) {
    svg.setAttribute('aria-hidden', 'true')
    svg.style.position = 'absolute'
    svg.style.width = 0
    svg.style.height = 0
    svg.style.overflow = 'hidden'
    prepend(svg,document.body)
  }
}

if(shouldInjectCss && !window.__iconfont__svg__cssinject__){
  window.__iconfont__svg__cssinject__ = true
  try{
    document.write("<style>.svgfont {display: inline-block;width: 1em;height: 1em;fill: currentColor;vertical-align: -0.1em;font-size:16px;}</style>");
  }catch(e){
    console && console.log(e)
  }
}

ready(appendSvg)


})(window)
