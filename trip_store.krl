ruleset trip_store {
  meta {
    name "Track Trips"
    author "Ben Jacobson"
    logging on
    shares __testing
  }

  global {
    __testing = {
      "events": [{
        "domain": "init",
        "type": "ent"
      }]
    }
    init_trisp = []
  }

  rule init_ent {
    select when init ent
    always {
      ent:trips := init_trips
    }
  }

  rule collect_trips {
    select when explicit trip_processed
  }
}