CREATE TABLE bad_posts (
    id SERIAL PRIMARY KEY,
    topic VARCHAR(50),
    username VARCHAR(50),
    title VARCHAR(150),
    url VARCHAR(4000) DEFAULT NULL,
    text_content TEXT DEFAULT NULL,
    upvotes TEXT,
    downvotes TEXT
);
CREATE TABLE bad_comments (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50),
    post_id BIGINT,
    text_content TEXT
);
INSERT INTO "bad_posts" VALUES(
    (1,'Synergized','Gus32','numquam quia laudantium non sed libero optio sit aliquid aut voluptatem',NULL,'Voluptate ut similique libero architecto accusantium inventore fuga. Maxime est consequatur repellendus commodi. Consequatur veniam debitis consequatur. Et eaque a. Magnam ea rerum eos modi. Accusamus aut impedit perferendis. Quasi est ipsum.','Judah.Okuneva94,Dasia98,Maurice_Dooley14,Dangelo_Lynch59,Brandi.Schaefer,Jayde.Kulas74,Katarina_Hudson,Ken.Murphy42','Lambert.Buckridge0,Joseph_Pouros82,Jesse_Yost'),
    (2,'Applications','Keagan_Howell','officia temporibus molestias sequi ea qui','http://lesley.com',NULL,'Marcellus31,Amina_Larson,Vicky_Hilll,Angelo_Aufderhar64,Javier25,Wilhelmine99,Danika_Renner88','Aniyah_Balistreri68,Demarcus.Berge,Melody.Ondricka,Ruben_Kuvalis,Marlin_Klocko7,Dangelo_Lynch59,Alana_Mayer17,Caleigh.McKenzie'),
    (3,'Buckinghamshire','Gertrude.Nicolas48','officiis accusamus qui at blanditiis dolor sit','http://aurelie.name',NULL,'Evangeline.Koss65,Adolfo_Ward,Ariel.Armstrong,Domingo_Ratke,Noble41','Reinhold.Little,Rosalyn44,Ezequiel_Lindgren,Adriel50,Keith.Schroeder,Opal.Schulist22,Carissa54,Lora7,Eudora_Dickinson68,Morgan.Aufderhar89'))
