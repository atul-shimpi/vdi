CREATE TABLE softwares (
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	name VARCHAR(255),
	version VARCHAR(255),
	license_count INT,
	download_link VARCHAR(255),
	license_detail VARCHAR(255),
	is_free BOOLEAN
);
CREATE TABLE license_requests
(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	request_id INT,
	approval_id INT,
	software_id INT,
	count INT,
	status VARCHAR(255)
);

CREATE TABLE templates_softwares (
	template_id INT  NOT NULL,
	software_id INT  NOT NULL
);

INSERT INTO actions (ACTION,controller,description) VALUES('index','license_requests','index page of license_requests');

INSERT INTO actions (ACTION,controller,description) VALUES('new','license_requests','page to create new license_requests page');

INSERT INTO actions (ACTION,controller,description) VALUES('add','license_requests','create new license_requests page');

INSERT INTO actions (ACTION,controller,description) VALUES('edit','license_requests','edit page of license_requests');

INSERT INTO actions (ACTION,controller,description) VALUES('update','license_requests','update license_requests');

INSERT INTO actions (ACTION,controller,description) VALUES('show','license_requests','show page of license_requests');

INSERT INTO actions (ACTION,controller,description) VALUES('index','softwares','index page of softwares');

INSERT INTO actions (ACTION,controller,description) VALUES('new','softwares','page create new softwares page');

INSERT INTO actions (ACTION,controller,description) VALUES('add','softwares','create new softwares page');

INSERT INTO actions (ACTION,controller,description) VALUES('edit','softwares','edit page of softwares');

INSERT INTO actions (ACTION,controller,description) VALUES('update','softwares','update softwares');

INSERT INTO actions (ACTION,controller,description) VALUES('show','softwares','show page of softwares');

INSERT INTO actions (ACTION,controller,description) VALUES('license_detail','softwares','license_detail page of softwares');
