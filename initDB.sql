-- TABLES

CREATE TABLE users (
	id varchar(15) NOT NULL,
	email varchar(40) NOT NULL,
	name varchar(15) NOT NULL,
	lastname varchar(15) NOT NULL,
	password varchar(255) NOT NULL,
	CONSTRAINT users_pkey PRIMARY KEY (id)
);
CREATE TABLE admins (
	id varchar(15) NOT NULL,
	CONSTRAINT admins_pkey PRIMARY KEY (id),
	CONSTRAINT admins_id_fkey FOREIGN KEY (id) REFERENCES users(id)
);
CREATE TABLE rooms (
	id varchar(10) NOT NULL,
	name varchar(15) NOT NULL,
	admin_id varchar(15) NOT NULL,
	start_date timestamptz NULL,
	end_date timestamptz NULL,
	CONSTRAINT rooms_pkey PRIMARY KEY (id),
	CONSTRAINT rooms_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES admins(id)
);

CREATE TABLE checkemail (
	id varchar(15) NOT NULL,
	token int NOT NULL,
	creation_date timestamp NOT NULL,
	CONSTRAINT checkemail_pkey PRIMARY KEY (id)
);

CREATE TABLE doubleauthentication (
	id varchar(50) NOT NULL,
	token varchar(255) NOT NULL,
	creation_date timestamp NOT NULL,
	CONSTRAINT doubleauthentication_pkey PRIMARY KEY (id),
	CONSTRAINT doubleauthentication_id_fkey FOREIGN KEY (id) REFERENCES users(id)
);

CREATE TABLE feedback (
	id serial NOT NULL,
	rating int NOT NULL,
	comment varchar(255) NOT NULL,
	room_id varchar(10) NOT NULL,
	user_id varchar(15) NOT NULL,
	CONSTRAINT feedback_pkey PRIMARY KEY (id),
	CONSTRAINT feedback_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id),
	CONSTRAINT feedback_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)
);


CREATE TABLE questions (
	order_question int NOT NULL,
	title varchar(100) NOT NULL,
	assignement varchar(500) NOT NULL,
	suggestion varchar(500) NOT NULL,
	answer varchar(500) NOT NULL,
	room_id varchar(500) NOT NULL,
	CONSTRAINT questions_pkey PRIMARY KEY (order_question, room_id),
	CONSTRAINT questions_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id)
);

CREATE TABLE retrievepassword (
	id varchar(50) NOT NULL,
	token int NOT NULL,
	creation_date timestamp NOT NULL,
	CONSTRAINT retrievepassword_pkey PRIMARY KEY (id),
	CONSTRAINT retrievepassword_id_fkey FOREIGN KEY (id) REFERENCES users(id)
);

CREATE TABLE scores (
	id serial NOT NULL,
	score int NOT NULL,
	user_id varchar(15) NOT NULL,
	room_id varchar(6) NOT NULL,
	CONSTRAINT scores_pkey PRIMARY KEY (id),
	CONSTRAINT scores_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id),
	CONSTRAINT scores_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE whitelist (
	user_id varchar(15) NOT NULL,
	room_id varchar(10) NOT NULL,
	CONSTRAINT invitation_pkey PRIMARY KEY (user_id, room_id),
	CONSTRAINT invitation_room_id_fkey FOREIGN KEY (room_id) REFERENCES rooms(id),
	CONSTRAINT invitation_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Fonctions

CREATE OR REPLACE FUNCTION replace_existing_tuple_checkemail()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (SELECT 1 FROM checkemail WHERE id = NEW.id) THEN
        UPDATE checkemail SET token = NEW.token, creation_date = NEW.creation_date WHERE id = NEW.id;
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION replace_existing_tuple_doubleauthentication()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (SELECT 1 FROM DoubleAuthentication WHERE id = NEW.id) THEN
        UPDATE DoubleAuthentication SET token = NEW.token, creation_date = NEW.creation_date WHERE id = NEW.id;
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$function$
;


CREATE OR REPLACE FUNCTION replace_existing_tuple()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF EXISTS (SELECT 1 FROM retrievepassword WHERE id = NEW.id) THEN
        UPDATE retrievepassword SET token = NEW.token, creation_date = NEW.creation_date WHERE id = NEW.id;
        RETURN NULL;
    ELSE
        RETURN NEW;
    END IF;
END;
$function$
;

CREATE OR REPLACE FUNCTION check_white_list()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
  IF  EXISTS (SELECT 1 FROM Whitelist WHERE user_id = NEW.user_id AND room_id = NEW.room_id) THEN
  	return null;
  else
  	return new;
  END IF;
END;
$function$
;

-- Triggers

create trigger replace_tuple_checkemail before
insert
    on
    checkemail for each row execute procedure replace_existing_tuple_checkemail();


create trigger replace_tuple_doubleauthentication before
insert
    on
    doubleauthentication for each row execute procedure replace_existing_tuple_doubleauthentication();

create trigger replace_tuple_password before
insert
    on
    retrievepassword for each row execute procedure replace_existing_tuple();

create trigger trigger_whitelist before
insert
    on
    whitelist for each row execute procedure check_white_list();

-- data

INSERT INTO users (id,email,name,lastname,password) VALUES
	 ('johndoe','johndoe@example.com','John','Doe',''),
	 ('janedoe','janedoe@example.com','Jane','Doe',''),
	 ('jimsmith','jimsmith@example.com','Jim','Smith',''),
	 ('kevin','dupond@example.com','Kevin','Dupond',''),
	 ('jean','johndoe@example.com','Jean','Dubois',''),
	 ('sarahjones','sarahjones@example.com','Sarah','Jones','');

INSERT INTO admins (id) VALUES
	 ('johndoe');

INSERT INTO rooms (id,name,admin_id,start_date,end_date) VALUES
	 ('practice','Practice','johndoe',NULL,NULL),
	 ('game','Game','johndoe',NULL,NULL);

INSERT INTO questions (order_question,title,assignement,suggestion,answer,room_id) VALUES
	 (2,'Connectez-vous au terminal d’un serveur sécurisé','À cette étape, vous ne pouvez plus utiliser votre machine pour réaliser des tests. En effet, votre machine pourrait se retrouver infectée à son tour. Cherchez le protocole permettant de vous connecter à la machine qui possède l’ip 82.168.85.162 avec le nom d’utilisateur franklin','Le protocole à utiliser est le protocole ssh','ssh franklin@82.168.85.162','game'),
	 (4,'Retrouvez l''ip source','On a découvert que les attaquants communiquent encore avec le serveur contaminé. Ils cherchent à le commander à l’aide du protocole ssh. Une trame capturée par un de vos collègues à l''aide de l''outil wireshark se trouve dans votre répertoire courant. À l''aide du terminal, lisez là et insérez l''ip source dans le terminal. Cette ip est le pas final vers l’identité des assaillants. La trame se nomme « tramessh.txt ». Une fois cette ip trouvée, la police pourra se charger de trouver leur identité','Pour visualiser la trame, il vous suffit de taper la commande "cat tramessh.txt". La trame possède un entête. Cherchez à déterminer chaque champ par rapport à votre cours afin de trouver l''ip. Le champ de l''ip de source commence au 26ème octet et finit au 29ème','162.159.134.234','game'),
	 (12,'Ipv6 locale','Ipv6 locale ','La commande est la même que pour consulter l’ipv4 ','ifconfig','practice'),
	 (11,'Récupération du contenu d’une page','Récupérez le code de la page accessible à l’url suivante : findthebreach.ddns.net/contenu.html ','Utilisez la commande curl','curl findthebreach.ddns.net/contenu.html','practice'),
	 (3,'Masque de sous-réseau','Avec l''aide du terminal ci-contre essayez de trouver le masque de sous-réseau et identifiez la plus petite adresse IPv4 qu''un hôte peut avoir sur ce réseau  ','Utilisez la commande ifconfig ','192.168.1.1','practice'),
	 (2,'Récupérer l adresse MAC','Avec l''aide du terminal ci-contre essayez de trouver l''adresse MAC de la machine. ','Utilisez la commande ip link show','a0:48:1c:9a:67:dd','practice'),
	 (5,'Ip source depuis une trame','Avec l''aide du terminal ci-contre essayez de trouver l''adresse Ip de source du message contenu dans la trame, se trouvant dans le fichier trame','L''adresse Ip de source commence au 27eme octet et finit au 30eme octet ','139.124.187.29 ','practice'),
	 (6,'Ip du destinataire depuis une trame','Avec l''aide du terminal ci-contre essayez de trouver l''adresse Ip du destinataire du message contenu dans la trame, se trouvant dans le fichier trame.txt','L''adresse Ip de source commence au 31eme octet et finit au 34eme octet',' 139.124.1.2','practice');
INSERT INTO questions (order_question,title,assignement,suggestion,answer,room_id) VALUES
	 (7,'Consultation de la table de routage','Comment pouvons-nous consulter la table de routage sur notre ordinateur avec la commande netstat ?','En utilisant la commande netstat avec un parametre vous pouvez afficher la table de routage','netstat –r','practice'),
	 (8,'Trouver l ip derrière un nom de domaine','Avec la commande nslookup, trouvez l''''ip de google.fr','Utilisez la commande de cette manière nslookup nomDeDomaine','nslookup google.fr','practice'),
	 (9,'Vérifier les connections','Comment pouvons-nous afficher les connexions actives sur notre ordinateur ?','La commande est la même que celle pour les tables de routage que vous avez utilisé. Cette fois il ne faut pas d’arguments','netstat ','practice'),
	 (10,'Transfert de fichier sécurisé','Comment utilisons-nous des outils tels que scp pour transférer des fichiers vers ou depuis un serveur distant ? Envoyez un fichier appelé envoi.txt vers le serveur findthebreach.ddns.net avec l’utilisateur henri','La commande scp fonctionne sur le shéma suivant : scp fichier user@nomDeDomaine:','scp envoi.txt henri@findthebreach.ddns.net:','practice'),
	 (4,'Adresse MAC source depuis une trame',' Avec l''aide du terminal ci-contre essayez de trouver l''adresse MAC source du message contenu dans la trame, se trouvant dans le fichier trame','L''adresse MAC source commence au 7eme octet et finit au 12eme octet ','84 2b 2b a0 56 f8 ','practice'),
	 (13,'Trouvez l’utilisateur',' Utilisez le terminal pour trouver le nom de l’utilisateur  ','Utilisez une commande tres courte  ',' w','practice'),
	 (14,'Trouver une adresse IP à partir d’un DNS','Affichez l’adresse ip de notre site web ','Utiliser la commande host','host findthebreach.ddns.net','practice'),
	 (1,'Récupérer le contenu de la page ','On vous a signalé qu’une personne a laissé une signature sur le site de votre IUT. Récupérez le code de la page avec une commande dans le terminal. Cherchez la signature laissée et entrez là dans le terminal. Cette signature signifie que quelqu’un a accès au serveur où est hébergé le site. Le site est accessible à l’url suivante : findthebreach.ddns.net/index.php','La signature est en bas du code. Vous obtenez le code du site en tapant la commande curl findthebreach.ddns.net/index.php ','Georges Washington','game'),
	 (1,'Récupérer l adresse IP locale','Avec l''aide du terminal ci-contre essayez de trouver l''adresse IP locale de la machine.  ','Utilisez la commande ifconfig','192.168.1.1','practice'),
	 (3,'Connexions actives port 22','Visualiser les connexions actives sur le port 22. Le port 22 est celui utilisé pour communiquer avec une machine distante. Ceci vous permettra de savoir si votre serveur est toujours contrôlé par l’attaquant. ','Utilisez la commande netstat avec grep','netstat -tlnp | grep :22','game');
INSERT INTO questions (order_question,title,assignement,suggestion,answer,room_id) VALUES
	 (5,'Identité des attaquants','Maintenant que vous avez l’accès à l’ip de l’attaquant, vous allez chercher à savoir leur identité. Vous avez leur adresse ip, tentez maintenant de trouver un indice grâce à celle-ci. Entrez le nom une fois trouvé dans le terminal','Tentez de récupérer une page web ','Google','game'),
	 (15,'Trouver port Socket en écoute','Trouvez le dernier socket en écoute en mode TCP sur le réseau, et donnez le port qu’il utilise pour communiquer ','Il faut utiliser la commande ss avec un argument pour les sockets en écoute, et un pour le mode utilisé','ss -lt ','practice');

INSERT INTO scores (score,user_id,room_id) VALUES
	 (3082,'sarahjones','game'),
	 (2660,'janedoe','game'),
	 (1556,'jimsmith','game'),
	 (4967,'kevin','game'),
	 (3867,'jean','game');

INSERT INTO feedback (rating,comment,room_id,user_id) VALUES
	 (1,'Trop dure','game','jimsmith'),
	 (3,'Un peu dure mais le chat m a aider','game','sarahjones'),
	 (4,'Trop facile !! ','game','johndoe');
	 (5,'Super salon ! et je suis 1er ah ah qui peut me battre','game','kevin');
