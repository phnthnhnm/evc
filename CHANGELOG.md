# Changelog

## [3.0.0](https://github.com/phnthnhnm/evc/compare/v2.2.0...v3.0.0) (2026-06-30)


### ⚠ BREAKING CHANGES

* **data:** resonators.json is now a mirror of the website's data and is auto-updated

### Features

* **data:** handle ID change migration ([6d278bd](https://github.com/phnthnhnm/evc/commit/6d278bde64c01420fc884ebaa2ee0ec0c512c415))
* **data:** resonators.json is now a mirror of the website's data and is auto-updated ([ba2e4c7](https://github.com/phnthnhnm/evc/commit/ba2e4c7244414c1202f435ca22e0c45314cdb5b1))
* **navigation:** add keyboard navigation and adjacent resonator navigation ([5c397b5](https://github.com/phnthnhnm/evc/commit/5c397b57f896ec56581453e5c40c323d39d248a9))
* **navigation:** pressing Esc will navigate to parent screen ([2f08f9d](https://github.com/phnthnhnm/evc/commit/2f08f9dfd8a95277a02758b9e95f2fe05934d7fe))
* remove 'Default' team placeholder from seed resonators ([f977ed2](https://github.com/phnthnhnm/evc/commit/f977ed2e594235ee8e48d5970bae98057b39aaab))
* **resonator_detail:** add persistent ER controller and validation ([6f1fb71](https://github.com/phnthnhnm/evc/commit/6f1fb71180cfbbffdc47f9ba454b68b9f9c9539d))
* **resonator:** add Lucilla ([65bac62](https://github.com/phnthnhnm/evc/commit/65bac6268f5824dd6e8a5b20416f5fa4b1dcb053))
* **rework:** initial changes ([22bbc06](https://github.com/phnthnhnm/evc/commit/22bbc06960da58b53ad1f5000809f6643f24835d))
* **rework:** stage 2 ([dd38396](https://github.com/phnthnhnm/evc/commit/dd38396e65d88fe57dce746b3c527eb2ab62a88b))
* **rework:** stage 3 ([0d487e8](https://github.com/phnthnhnm/evc/commit/0d487e83bf0b10be7683faaac6de33b2c7dc08b2))
* **rework:** stage 4 ([5a24361](https://github.com/phnthnhnm/evc/commit/5a2436108fbd0460d9fab441dc6b3f8cf331da30))
* **ui:** add visual warning for echoes with &gt;5 non-zero stats ([2fb9617](https://github.com/phnthnhnm/evc/commit/2fb9617acc254b280ab269d0c34ad2fabc97ca79))
* **user-guide:** add contextual help popups for team and ER input fields ([251cd60](https://github.com/phnthnhnm/evc/commit/251cd60993e3a1f7756548b7cab29831b16a5f21))


### Bug Fixes

* **data:** backup/restore data operations now correctly spawn toasts and invalidate cached echo sets ([1577d72](https://github.com/phnthnhnm/evc/commit/1577d727eb857988de931381ef05a12c6493a8e3))
* normalize echo slot suffixes on stat keys when serializing/deserializing ([54d920a](https://github.com/phnthnhnm/evc/commit/54d920a609f3d68a2765a1adecdd3584f5216027))
* **ui:** add tooltip to resonator name for truncated text ([d846182](https://github.com/phnthnhnm/evc/commit/d8461825436267cbe2701e1da8d78cb1a47db3b0))
* use context.mounted instead of mounted in echo compare screen ([fa86964](https://github.com/phnthnhnm/evc/commit/fa869647feb7e05ae5ae0f7771d036a791cee2c4))
