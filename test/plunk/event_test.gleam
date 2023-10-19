import gleeunit/should
import gleam/erlang/os
import gleam/io
import gleam/json
import gleam/result
import gleam/hackney
import plunk/instance.{Instance}
import plunk/event.{Event}

pub fn track_test() {
  let key =
    os.get_env("PLUNK_API_KEY")
    |> result.unwrap("")

  let req =
    Instance(api_key: key)
    |> event.track(Event(
      event: "your-event",
      email: "someone@example.com",
      data: [#("name", json.string("John"))],
    ))

  case hackney.send(req) {
    Ok(resp) -> {
      let d = event.decode(resp)
      should.be_ok(d)

      let assert Ok(data) = d
      should.equal(data.success, True)
      io.debug(data)
      Nil
    }
    Error(e) -> {
      io.debug(e)
      should.fail()
    }
  }
}
