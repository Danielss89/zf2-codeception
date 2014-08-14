<?php
$I = new AcceptanceTester($scenario);
$I->wantTo('Signin and out');

$I->amOnPage('/user/login');
$I->see('Sign In');
$I->fillField('identity', "test@test.com");
$I->fillField('credential', 'password');
$I->click('Sign In');

$I->seeCurrentUrlEquals('/user');
$I->see('Hello, test!');
$I->seeLink('[Sign Out]', '/user/logout');

$I->click('[Sign Out]');
$I->seeCurrentUrlEquals('/user/login');
