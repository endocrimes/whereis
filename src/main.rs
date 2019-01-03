#![feature(proc_macro_hygiene, decl_macro)]

#[macro_use]
extern crate rocket;
extern crate rocket_contrib;
extern crate serde;

use rocket_contrib::templates::Template;
use serde::Serialize;
use std::collections::HashMap;

#[derive(Clone, PartialEq)]
enum ContextValue {
    Null,
    String(String),
    Int(i64),
    HashMap(HashMap<String, ContextValue>),
}

impl Serialize for ContextValue {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: ::serde::Serializer,
    {
        match *self {
            ContextValue::Null => serializer.serialize_unit(),
            ContextValue::Int(ref n) => n.serialize(serializer),
            ContextValue::String(ref s) => serializer.serialize_str(s),
            ContextValue::HashMap(ref m) => m.serialize(serializer),
        }
    }
}

#[get("/")]
fn index() -> Template {
    let mut context = HashMap::<String, ContextValue>::new();
    let mut location = HashMap::<String, ContextValue>::new();
    location.insert("time_zone_offset".to_owned(), ContextValue::Int(60));
    location.insert("time_zone_offset_hours".to_owned(), ContextValue::Int(1));
    location.insert("time_zone_offset_minutes".to_owned(), ContextValue::Int(0));
    location.insert(
        "pretty_name".to_owned(),
        ContextValue::String("Berlin Germany".to_owned()),
    );
    context.insert("location".to_owned(), ContextValue::HashMap(location));
    context.insert(
        "personName".to_owned(),
        ContextValue::String("Danielle".to_owned()),
    );
    context.insert(
        "personPronoun".to_owned(),
        ContextValue::String("her".to_owned()),
    );
    context.insert(
        "GOOGLE_MAPS_TOKEN".to_owned(),
        ContextValue::String("nope".to_owned()),
    );
    Template::render("index", context)
}

fn main() {
    rocket::ignite()
        .mount("/", routes![index])
        .attach(Template::fairing())
        .launch();
}
