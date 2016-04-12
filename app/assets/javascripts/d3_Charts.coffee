$(".channel.fitbit").ready ->
  $.getJSON '/channels/fitbit.json', (heartData) ->
    console.log(heartData)
    # LINE CHART
    # SVG Window Width & Height
    h = 200
    w = 1000

    lineFunc = d3.svg.line()
    .x((d) ->
      # WIDTH OF WINDOW * (CONCATINATION OF HOUR MIN SECTIONS / MAXIMUM NUMBER (24 hours + 60 min + 60 seconds))
      (w * (parseFloat("" + d.hour + d.minuites + d.seconds)))/ 246060
    )
    .y((d) ->
      # HEIGHT OF WINDOW - VALUE
      h - d.body
    )
    .interpolate('linear')

    svg = d3.select('#fitbitGraph').append('svg').attr(
      width: w
      height: h)

    viz = svg.append('path').attr(
      d: lineFunc(heartData)
      'stroke': '#FFCC00'
      'stroke-width': 2
      'fill': 'none')
