module evloop::loop;
import std::collections::list;
import evloop::async;
import evloop::coroutine;

def AsyncList = List(<Async>);
struct EvLoop {
   AsyncList coroutines;
}

fn EvLoop new() {
  AsyncList list;
  list.new_init();
  EvLoop evloop = {list};
  return evloop;
}

fn void* EvLoop.run(&self, Coroutine coroutine, void* args) {
  CoroutineCtx ctx = {coroutine, 0, args, self};
  Async result = coroutine(ctx);
  while (result.is_active()) {
    result = coroutine(result.ctx);
  }
  return result.ctx.out;
}

fn void EvLoop.progress(&self) {
  Async! func = self.get_next();
  if (try func) {
    if (func.is_active()) {
      func = func.ctx.coroutine(func.ctx);
      if (func.status == CoroutineStatus.RUNNING) {
        if (self.coroutines.size > 0) {
          self.coroutines.push_front(func);
        }
        else {
          self.coroutines.push(func);
        }
      }
    }
  }
}

fn void EvLoop.loop_progress(&self) {
  while (self.coroutines.size > 0) {
    self.progress();
  }
}

fn void EvLoop.add_coroutine(&self, Coroutine coroutine, void* args) {
  Async func = {CoroutineStatus.PENDING, {coroutine, 0, args, self}};
  self.coroutines.push(func);
}

fn Async! EvLoop.get_next(&self) {
  return self.coroutines.pop(); 
}

