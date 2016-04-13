$(".channel.fitbit").ready ->
  $.getJSON '/channels/fitbit.json', (heartData) ->

    # LOCAL VARIABLES
    maxHeart = Math.max.apply(Math, heartData.map((data) ->
      data.body
    ))
    minHeart = Math.min.apply(Math, heartData.map((data) ->
      data.body
    ))

    maxDate = Math.max.apply(Math, heartData.map((data)->
      246060
    ))
    minDate = Math.min.apply(Math, heartData.map((data)->
      0
    ))

    # LINE CHART
    # SVG Window Width & Height
    h = 300 # Dynamically set canvas height + a little padding
    w = 1000 # Do not use dynamic width; number of seconds in a day is static.
    padding = 25;

    getHour = (d) ->
      strDate = new String(d)
      console.log(strDate)
      first_hour = strDate.substr(0, 1)
      second_hour = strDate.substr(1,1)
      if second_hour == "0" && strDate.length != 6
        return first_hour
      else
        return first_hour + second_hour
      # console.log(hour)

    # Tool Tip
    tooltip = d3.select("#fitbitGraph").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0)

    # SCALES
    xScale = d3.scale
      .linear() # Can be .log or .pow
      .domain([minDate, maxDate]) #Input min/max of input data
      .range([padding + 5, w - padding - 5]); # Changes where the line starts

    yScale = d3.scale
      .linear()
      .domain([40, maxHeart]) #May change 0 here for 40
      .range([h, 10]);

    # CREATE AXIS
    xAxisGen = d3.svg.axis().scale(xScale).orient("bottom").ticks(24).tickFormat (d) -> getHour(d)
    yAxisGen = d3.svg.axis().scale(yScale).orient("left").ticks(5)

    # CREATE LINE
    lineFunc = d3.svg.line()
    .x((d) ->
      xScale((parseFloat("" + d.hour + d.minuites + d.seconds)))
    )
    .y((d) ->
      yScale(d.body)
    )
    .interpolate('linear')

    # APPEND DATA
    svg = d3.select('#fitbitGraph').append('svg').attr(
      width: w
      height: h
    )
    # APPEND AXIS
    yAxis = svg.append('g').call(yAxisGen)
      .attr("class", "axis")
      .attr("transform", "translate(" + padding + ", 0)"); # Move over a bit to show axis

    xAxis = svg.append('g').call(xAxisGen)
      .attr("class", "axis")
      .attr("transform", "translate(0," + (h-padding) + ")"); # Move over a bit to show axis

    viz = svg.append('path').attr(
      d: lineFunc(heartData)
      'stroke': '#FFCC00'
      'stroke-width': 2
      'fill': 'none')

    dots = svg.selectAll('circle')
      .data(heartData)
      .enter()
      .append("circle")
      .attr({
        cx: (d) ->
          xScale((parseFloat("" + d.hour + d.minuites + d.seconds)))
        cy: (d) ->
          yScale(d.body)
        r: 5,
        "fill": "#FFCC00",
        class: "circle"
      }).style('opacity', .05)
      .on('mouseover', (d) ->
        tooltip.transition()
          .duration(500)
          .style("opacity", .85)

        tooltip.html("<strong>"+ d.body + " BPM </strong>")
          .style("left", (d3.event.pageX) + "px")
          .style("top", (d3.event.pageY - 28) + "px");
      )
      .on('mouseout', (d) ->
        tooltip.transition()
          .duration(500)
          .style("opacity", 0);
      )

    # LABELS: NEED TO LIMIT NUMBER...
    # labels = svg.selectAll('text').data(heartData).enter().append('text').text((d) ->
    #   d.body
    # ).attr(
    #   x: (d) ->
    #     xScale((parseFloat("" + d.hour + d.minuites + d.seconds)))
    #   y: (d) ->
    #     yScale(d.body)
    #   'font-size': '12px'
    #   'font-family': 'sans-serif'
    #   'fill': '#666666'
    #   'text-anchor': 'start'
    #   'dy': '.35em'
    #   'font-weight': (d, i) ->
    #     if i == 0 or i == heartData.length - 1
    #       'bold'
    #     else
    #       'normal'
    # )


