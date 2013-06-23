$(document).ready ->
    canvas = $("canvas")[0]
    context = canvas.getContext("2d")

    clear_canvas = -> context.clearRect 0, 0, canvas.width, canvas.height

    linterp = (x0, x1, y0, y1) ->
        (x) -> y0 + (x - x0) * (y1 - y0) / (x1 - x0)
    
    [xmin, xmax] = [-2, 2]
    [ymin, ymax] = [0, 4.2]

    pix_to_real_x = linterp(0, canvas.width, xmin, xmax)
    pix_to_real_y = linterp(canvas.height, 0, ymin, ymax)
    real_to_pix_x = linterp(xmin, xmax, 0, canvas.width)
    real_to_pix_y = linterp(ymin, ymax, canvas.height, 0)

    draw_circle = (x, y, radius, color) ->
        context.beginPath()
        context.arc(real_to_pix_x(x), real_to_pix_y(y), radius, 0, 2 * Math.PI, false)
        context.fillStyle = color
        context.fill()

    plot_fn = (fn) ->
        context.beginPath()
        context.strokeStyle = "black"
        context.moveTo 0, fn(xmin)
        for pix_x in [1..canvas.width]
            x = pix_to_real_x(pix_x)
            y = fn(x)
            pix_y = Math.round real_to_pix_y(y)
            context.lineTo pix_x, pix_y
        context.stroke()

    potential_fn = (x) -> x*x
    potential_fn_grad = (x) -> x / 2.0

    setup_scene = ->
        clear_canvas()
        plot_fn(potential_fn)

    class Ball
        constructor: (@x, @color) ->
            @amp = x
            @vx = 0

        add_to_scene: ->
            draw_circle(@x, potential_fn(@x), 5, @color)

        update_analytic: (t) ->
            freq = 1
            @x = @amp * Math.cos(freq * t)
            @vx = -@amp * Math.sin(freq * t)

        update_euler: (dt) ->
            @vx -= dt * potential_fn_grad(@x)
            @x += dt * @vx

    analytic_ball = new Ball 1.5, "blue"
    euler_ball = new Ball 1.5, "green"
    time = 0
    timestep = .01
    iter = 0

    xplot = $("#xplot")
    xdata = new Array
    vxplot = $("#vxplot")
    vxdata = new Array

    update_fn = ->
        setup_scene()
        analytic_ball.update_analytic(time)
        euler_ball.update_euler(timestep)
        for ball in [analytic_ball, euler_ball]
            ball.add_to_scene()
        iter += 1
        time += timestep

    update_fn()
    setInterval update_fn, 10

    

