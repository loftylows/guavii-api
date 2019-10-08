{application,redbird,
             [{applications,[kernel,stdlib,elixir,logger]},
              {description,"A Redis adapter for Plug.Session"},
              {modules,['Elixir.Mix.Tasks.Redbird.DeleteAllSessions',
                        'Elixir.Plug.Session.REDIS','Elixir.Redbird',
                        'Elixir.Redbird.Redis','Elixir.Redbird.RedisError']},
              {registered,[]},
              {vsn,"0.4.0"},
              {mod,{'Elixir.Redbird',[]}}]}.
