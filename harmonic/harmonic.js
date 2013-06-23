// Generated by CoffeeScript 1.4.0
(function() {

  $(document).ready(function() {
    var Ball, analytic_ball, canvas, clear_canvas, context, draw_circle, euler_ball, linterp, pix_to_real_x, pix_to_real_y, plot_fn, potential_fn, potential_fn_grad, real_to_pix_x, real_to_pix_y, setup_scene, time, timestep, update_fn, vxplot, xmax, xmin, xplot, ymax, ymin, _ref, _ref1;
    canvas = $("canvas")[0];
    context = canvas.getContext("2d");
    clear_canvas = function() {
      return context.clearRect(0, 0, canvas.width, canvas.height);
    };
    linterp = function(x0, x1, y0, y1) {
      return function(x) {
        return y0 + (x - x0) * (y1 - y0) / (x1 - x0);
      };
    };
    _ref = [-2, 2], xmin = _ref[0], xmax = _ref[1];
    _ref1 = [0, 4.2], ymin = _ref1[0], ymax = _ref1[1];
    pix_to_real_x = linterp(0, canvas.width, xmin, xmax);
    pix_to_real_y = linterp(canvas.height, 0, ymin, ymax);
    real_to_pix_x = linterp(xmin, xmax, 0, canvas.width);
    real_to_pix_y = linterp(ymin, ymax, canvas.height, 0);
    draw_circle = function(x, y, radius, color) {
      context.beginPath();
      context.arc(real_to_pix_x(x), real_to_pix_y(y), radius, 0, 2 * Math.PI, false);
      context.fillStyle = color;
      return context.fill();
    };
    plot_fn = function(fn) {
      var pix_x, pix_y, x, y, _i, _ref2;
      context.beginPath();
      context.strokeStyle = "black";
      context.moveTo(0, fn(xmin));
      for (pix_x = _i = 1, _ref2 = canvas.width; 1 <= _ref2 ? _i <= _ref2 : _i >= _ref2; pix_x = 1 <= _ref2 ? ++_i : --_i) {
        x = pix_to_real_x(pix_x);
        y = fn(x);
        pix_y = Math.round(real_to_pix_y(y));
        context.lineTo(pix_x, pix_y);
      }
      return context.stroke();
    };
    potential_fn = function(x) {
      return x * x;
    };
    potential_fn_grad = function(x) {
      return x / 2.0;
    };
    setup_scene = function() {
      clear_canvas();
      return plot_fn(potential_fn);
    };
    Ball = (function() {

      function Ball(x, color) {
        this.x = x;
        this.color = color;
        this.amp = x;
        this.vx = 0;
      }

      Ball.prototype.add_to_scene = function() {
        return draw_circle(this.x, potential_fn(this.x), 5, this.color);
      };

      Ball.prototype.update_analytic = function(t) {
        var freq;
        freq = 1;
        this.x = this.amp * Math.cos(freq * t);
        return this.vx = -this.amp * Math.sin(freq * t);
      };

      Ball.prototype.update_euler = function(dt) {
        this.vx -= dt * potential_fn_grad(this.x);
        return this.x += dt * this.vx;
      };

      return Ball;

    })();
    analytic_ball = new Ball(1.5, "blue");
    euler_ball = new Ball(1.5, "green");
    time = 0;
    timestep = .01;
    xplot = $("#xplot");
    vxplot = $("#vxplot");
    update_fn = function() {
      var ball, _i, _len, _ref2;
      setup_scene();
      analytic_ball.update_analytic(time);
      euler_ball.update_euler(timestep);
      _ref2 = [analytic_ball, euler_ball];
      for (_i = 0, _len = _ref2.length; _i < _len; _i++) {
        ball = _ref2[_i];
        ball.add_to_scene();
      }
      return time += timestep;
    };
    update_fn();
    return setInterval(update_fn, 10);
  });

}).call(this);
