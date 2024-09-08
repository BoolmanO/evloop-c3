module evloop::loop;
import std::collections::list;
import evloop::async;
import evloop::coroutine;

struct EvLoop {
  List(<Async>) coroutines;
}

fn EvLoop new() {
  List(<Async>) list;
  list.new_init();
  EvLoop evloop = EvLoop {list};
  return evloop;
}

fn void* EvLoop.run(EvLoop* evloop, Coroutine coroutine, void* args) {
  CoroutineCtx ctx = {coroutine, 0, args, evloop};
  Async result = coroutine(ctx);
  while (result.status != CoroutineStatus.FINISHED && result.status != CoroutineStatus.TERMINATED) {
    result = coroutine(result.ctx);
  }
  return result.ctx.out;
}

fn void EvLoop.progress(EvLoop* evloop) {
  Async! func = evloop.get_next();
  if (try func) {
    if (func.status != CoroutineStatus.FINISHED && func.status != CoroutineStatus.TERMINATED) {
      func = func.ctx.coroutine(func.ctx);
      if (func.status == CoroutineStatus.RUNNING) {
        if (evloop.coroutines.size > 0) {
          evloop.coroutines.push_front(func);
        }
        else {
          evloop.coroutines.push(func);
        }
      }
    }
  }
}

fn void EvLoop.loop_progress(EvLoop* evloop) {
  while (evloop.coroutines.size > 0) {
    evloop.progress();
  }
}

fn void EvLoop.add_coroutine(EvLoop* evloop, Coroutine coroutine, void* args) {
  Async func = {CoroutineStatus.PENDING, {coroutine, 0, args, evloop}};
  evloop.coroutines.push(func);
}

fn Async! EvLoop.get_next(EvLoop* evloop) {
  return evloop.coroutines.pop(); 
}

