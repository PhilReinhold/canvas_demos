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

    potential_fn = (x) -> x*x / 2.0
    potential_fn_grad = (x) -> x

    setup_scene = ->
        clear_canvas()
        plot_fn(potential_fn)

    class Ball
        constructor: (@x, @color) ->
            @amp = x
            @vx = 0
            @xhistory = new Array
            @vxhistory = new Array

        add_to_scene: ->
            draw_circle(@x, potential_fn(@x), 5, @color)
    
        update_history: (t) ->
            @xhistory.push([t, @x])
            @vxhistory.push([t, @vx])

        update_analytic: (t) ->
            freq = 1
            @x = @amp * Math.cos(freq * t)
            @vx = -@amp * Math.sin(freq * t)
            @update_history(t)

        update_euler: (t, dt) ->
            @vx -= dt * potential_fn_grad(@x)
            @x += dt * @vx
            @update_history(t)

        update_rk4: (t, dt) ->
            k1 = -potential_fn_grad(@x)
            k2 = -potential_fn_grad(@x + dt*k1/2.0)
            k3 = -potential_fn_grad(@x + dt*k2/2.0)
            k4 = -potential_fn_grad(@x + dt*k3)
            @vx += dt * (k1 + 2*k2 + 2*k3 + k4) / 6.0
            @x += dt * @vx
            @update_history(t)

    class BallSim
        constructor: ->
            @xplot = $("#xplot")[0]
            @vxplot = $("#vxplot")[0]
            @timestep_spinner = $("#timestep")[0]

            $('#startbtn')[0].onclick = => @start()
            $('#stopbtn')[0].onclick = => @stop()
            $('#resetbtn')[0].onclick = => @initialize_state()

            @running = false
            @initialize_state()
            @update_fn()
            @start()

        initialize_state: ->
            @analytic_ball = new Ball 1.5, "blue"
            @euler_ball = new Ball 1.5, "green"
            @rk_ball = new Ball 1.5, "red"
            @balls = [@analytic_ball, @euler_ball, @rk_ball]
            @time = 0

        update_fn: ->
            console.log(@xplot, @timestep_spinner, @running, @analytic_ball, @balls, @time)
            setup_scene()
            timestep = parseFloat(@timestep_spinner.value)
            @analytic_ball.update_analytic(@time)
            @euler_ball.update_euler(@time, timestep)
            @rk_ball.update_rk4(@time, timestep)
            for ball in @balls
                ball.add_to_scene()
            $.plot(@xplot, (b.xhistory for b in @balls))
            $.plot(@vxplot, (b.vxhistory for b in @balls))

            @time += timestep

        start: ->
            if not @running
                @timer = setInterval (=> @update_fn()), 50
                @running = true

        stop: ->
            clearInterval @timer
            @running = false

    sim = new BallSim
