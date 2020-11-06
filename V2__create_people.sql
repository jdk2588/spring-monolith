use ftgo;

CREATE TABLE people
(
    id         BIGINT NOT NULL,
    first_name VARCHAR(255),
    last_name  VARCHAR(255),
    PRIMARY KEY (id)
) ENGINE = InnoDB;
