function spinner() {
    var sectorsCount = 16,
        color = "rainbow",
        width = 10,
        r1 = 7,
        r2 = 30,
        cx = r2 + width,
        cy = r2 + width,
        r = Raphael("spinner", r2 * 2 + width * 2, r2 * 2 + width * 2),
        
        sectors = [],
        opacity = [],
        beta = 2 * Math.PI / sectorsCount,

        pathParams = {stroke: color, "stroke-width": width, "stroke-linecap": "round"};
        Raphael.getColor.reset();
    for (var i = 0; i < sectorsCount; i++) {
        var alpha = beta * i - Math.PI / 2,
            cos = Math.cos(alpha),
            sin = Math.sin(alpha);
        opacity[i] = 1 / sectorsCount * i;
        sectors[i] = r.path([["M", cx + r1 * cos, cy + r1 * sin], ["L", cx + r2 * cos, cy + r2 * sin]]).attr(pathParams);
        if (color == "rainbow") {
            sectors[i].attr("stroke", Raphael.getColor());
        }
    }
    var tick;
    (function ticker() {
        opacity.unshift(opacity.pop());
        for (var i = 0; i < sectorsCount; i++) {
            sectors[i].attr("opacity", opacity[i]);
        }
        r.safari();
        tick = setTimeout(ticker, 1000 / sectorsCount);
    })();
    return function () {
        clearTimeout(tick);
        r.remove();
    };
}