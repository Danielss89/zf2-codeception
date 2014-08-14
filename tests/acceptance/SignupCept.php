<?php 
$I = new AcceptanceTester($scenario);
$I->wantTo('Signup and check i get signed in automaticly');

$I->amOnPage('/user/register');
$I->see('Register');
$I->fillField('email', "test@zf2.com");
$I->fillField('password', 'strong-password');
$I->fillField('passwordVerify', 'strong-password');
$I->click('Register');

$I->seeCurrentUrlEquals('/user');
$I->see('Hello, test!');
$I->seeLink('[Sign Out]', '/user/logout');
