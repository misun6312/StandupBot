# StandupBot

## Overview
StandupBot is an extensible Slack bot that executes daily repetitive Slack team tasks. The currently supported task types are
* Standup
* Greenkeeping

## Installation
In order to use StandupBot, you will need to install [Elixir](https://elixir-lang.org/install.html#distributions).

## Usage
### Defining a Config
In order to use this application, you will need to define a configuration file `standup_bot/priv/config.json` containing the job specs that you want to execute (you may need to create the `/priv` directory yourself). An example configuration file looks something like this:

```json
{
    "bot_token": "foo-111-bar-222",
    "tasks": {
        "standup": {
            "channel": "FOOBAR",
            "users": [
                "ABC123BC",
                "BI3290DD"
            ],
            "hour": 9,
            "minute": 45,
            "week_days": [
                1,
                2,
                3,
                4,
                5
            ]
        },
        "greenkeeping": {
            "channel": "FOOBAR",
            "users": [
                "ZO32B1O",
                "ADJASDF"
            ],
            "hour": 13,
            "minute": 35,
            "week_days": [
                2
            ],
            "github_token": "abc-123-def-456"
        }
    }
}
```
The `bot_token` field corresponds to your slack integration's auth token.

For each job, `channel` corresponds to the slack ID of the channel to post to. This can be found by right-clicking the desired channel in slack, and clicking "Copy Link". This link will contain the channel's slack ID at the end of the url (the ID will look something like `CGMQABH3K`).

For each job, `users` corresponds to the list of users that will be included in the rotation for getting pinged. You can find a Slack users' ID by going to their profile in Slack and clicking "More" -> "Copy MemberID" (the ID will look something like `TFCJ2EHMF`). Make sure you are looking at the user's full profile in Slack when you click the "More..." button in their about slide out, not just the preview view.

For each job, the timing parameters (`hour`, `minute`, `week_days`) determine when the job will trigger. Note that times  are in *US Central Time (military time)*. The `week_days` refers to days of the (work) week the notification should be sent out at, where 1=Monday and 7=Sunday.

### Testing
In order to test, there's a few steps you will need to follow.

1. You will want to create a test channel in Slack and use this channel in your config.
2. Add your bot to this test channel.
3. Run `mix deps.get` in the project directory to download necessary dependencies
4. Execute `./run.sh` script in project directory. This will start up the application and connect to Slack.
5. In your test channel, send the message `!teambot help`. If the bot is online, it should respond with a list of available commands.

Note that if you already have an instance of this bot running in your team channel, you should stop it first before testing locally.

### Deploying
Once you have tested and are ready to deploy this bot for your team, the easiest method is to
1. Install Elixir & git on the server
2. Clone this repository to the server
3. scp your config file to the server (`standup_bot/priv/config.json`, create the `priv` dir on the server first if it does not exist). Ex: `scp standup_bot/priv/config.json ubuntu@ec1-11-111-11-111.compute-1.amazonaws.com:standup_bot/priv/config.json`
4. Run `nohup ./run.sh &`. This will compile an executable and start running the bot as a background process. Output will log to `nohup.out`
