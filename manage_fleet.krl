ruleset manage_fleet {
  meta {
    name "Manage Fleet"
    author "Ben Jacobson"
    use module io.picolabs.pico alias wrangler
    logging on
    shares __testing, create_vehicle
  }

  global {
    __testing = {
      "events": [
        {
          "domain": "car",
          "type": "new_vehicle"
        },
        {
          "domain": "reset",
          "type": "sections"
        }
      ]
    }

    installRule = function(other_eci, rule_name) {
      event:send({
        "eci": other_eci,
        "eid": "install-ruleset",
        "domain": "pico",
        "type": "new_ruleset",
        "attrs": {
          "rid": rule_name
        } 
      })
    }

    subscribe = function(subscriber_name, subscriber_eci) {
      event:send({
        "eci": meta:eci,
        "eid": "subscription",
        "domain": "wrangler",
        "type": "subscription",
        "attrs": {
          "name": subscriber_name,
          "name_space": "fleet",
          "my_role": "fleet",
          "subscriber_role": "vehicle",
          "channel_type": "subscription",
          "subscriber_eci": subscriber_eci
        }
      })
    }
  }

  rule reset_sections {
    select when reset sections
    send_directive("sections reset")
    always {
      ent:sections := {}
    }
  }

  rule create_vehicle {
    select when car new_vehicle
    pre {
      name = event:attr("name")
      exists = ent:sections >< name
    }
    if name.isnull() || exists then
      send_directive("section_not_created")
        with name = name
    fired {
    } else {
      raise pico event "new_child_request"
        attributes { "dname": name, "color": "#FF69B4" }
    }
  }


  rule pico_child_initialized {
    select when pico child_initialized
    pre {
      new_child = event:attr("new_child")
      new_child_name = event:attr("rs_attrs"){"dname"}
      new_child_eci = new_child{"eci"}
    }
    installRule(new_child_eci, "Subscriptions")
    installRule(new_child_eci, "trip_store")
    installRule(new_child_eci, "track_trips")
    subscribe(new_child_name, new_child_eci)
    always {
      ent:sections{new_child_name} := new_child;
      ent:child_attrs := event:attrs()
    }
  }

  rule delete_child {
    select when delete child
    pre {
      name = event:attr("name")
      exists = ent:sections >< name
      child_to_delete = ent:sections{name}
    }
    if exists then
      send_directive("delete child")
        with name = name
    fired {
      raise pico event "delete_child_request"
        attributes child_to_delete;
      ent:sections{name} := null
    }
  }
}

// http://localhost:8080/sky/event/cj12iw94g00012suzycu2vzsv/delete-child/pico/delete_child_request?id=cj12xcjo7001gocuz5s3d3qxh&eci=cj12xcjo8001hocuz7b500owk
// http://localhost:8080/api/pico/cj12iw94c00002suzmdasp0hk/rm-channel/cj12xvxsq001kocuzmebiwcnb