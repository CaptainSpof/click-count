package fr.xebia.clickcount;

import javax.inject.Singleton;

@Singleton
public class Configuration {

    public String redisHost;
    public final int redisPort;
    public final int redisConnectionTimeout;  //milliseconds

    public Configuration() {
        redisHost = System.getenv("REDIS_HOST");
        // if environment variable unset, fallback to previous implementation
        redisHost = (redisHost == null) ? "redis" : redisHost;
        redisPort = 6379;
        redisConnectionTimeout = 2000;
    }
}
